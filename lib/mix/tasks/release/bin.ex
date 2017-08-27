defmodule Mix.Tasks.Release.Bin do
  use Mix.Task

  @shortdoc "Initialize and create 'bin/run' helper scripts for managing releases"
  def run([]), do: run([nil])
  def run([release_root]) do

    unless File.exists?("./rel/config.exs") do
      Mix.Task.run("release.init", [])
    end

    [
      "./bin/run",
      "./bin/package",
      "./rel/commands",
    ]
    |> Enum.each(fn dirname ->
         :ok = dirname |> Path.expand |> File.mkdir_p!
       end)

    appname = Mix.Project.config[:app]
    default_root = "/src/#{appname}rel"
    release_root = release_root || default_root
    module_name = appname |> Atom.to_string |> Macro.camelize


    """
    defmodule #{module_name}.ReleaseTasks do

      @doc\"""
      Distillery upgrades were not (for me anyway) clearning the assets
      cache, so this called after an upgrade using RPC.

          ./bin/run/rel rpc #{module_name}.ReleaseTasks clear_cache

      This was based on help from
      https://github.com/bitwalker/exrm/issues/206
      \"""
      def clear_cache do
        Phoenix.Config.clear_cache #{module_name}.Web.Endpoint
        Phoenix.Endpoint.Supervisor.warmup #{module_name}.Web.Endpoint
      end

      @doc\"""
      Migrate all database.

      Assuming you have structured your migratinos as zero-downtime
      migrations, you can call this method have a successful release.
      To be considered a zero-downtime migration implies that

      a) The deployed code does not leverage the updated data structure
      b) Post migration, the deployed code continues to work

      In other words, full backwards compatibility.  Expose the database
      structure first, and then leverage it in a subsequent release.

      To access this functionality, execute

          ./bin/run/rel rpc Nameui.ReleaseTasks migrate

      This was based on help from
      https://github.com/bitwalker/distillery/blob/master/docs/Running%20Migrations.md
      \"""
      def migrate, do: Enum.each(repos(), &run_migrations_for/1)

      def myapp do
        __MODULE__
        |> :application.get_application
        |> (fn {:ok, app} -> app end).()
      end

      defp repos, do: Application.get_env(myapp(), :ecto_repos, [])

      defp run_migrations_for(repo) do
        repo.config
        |> Keyword.get(:otp_app)
        |> (fn app ->
              IO.puts "Running migrations for \#{app}"
              Ecto.Migrator.run(repo, migrations_path(app), :up, all: true)
            end).()
      end

      defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
      defp priv_dir(app), do: "\#{:code.priv_dir(app)}"

    end
    """
    |> write!("./lib/#{appname}/release_tasks.ex")


    """
    #!/bin/bash
    mix deps.unlock --all && \\
      mix deps.get && \\
      mix compile && \\
      (cd assets && npm install && brunch build --production) && \\
      mix phx.digest
    """
    |> write!("./bin/package/prerelease")

    """
    #!/bin/bash
    mix release --upgrade
    """
    |> write!("./bin/package/release")


    """
    #!/bin/bash
    VERSION=$(mix version.current)
    REL_ROOT=#{release_root}

    if [[ ! -e ${REL_ROOT}/.git ]]; then
      (cd ${REL_ROOT} && git init)
    fi

    mkdir -p ${REL_ROOT}/releases/${VERSION}

    cp ./_build/prod/rel/#{appname}/releases/${VERSION}/#{appname}.tar.gz ${REL_ROOT}/releases/${VERSION}/#{appname}.tar.gz
    (cd ${REL_ROOT} && \\
     ln -sf releases/${VERSION}/#{appname}.tar.gz #{appname}.tar.gz && \\
     git add -f releases/${VERSION}/#{appname}.tar.gz && \\
     git add #{appname}.tar.gz && \\
     git commit -m "v${VERSION}" && \\
     git push)
    """
    |> write!("./bin/package/retain")


    """
    #!/bin/bash

    if [[ ! -e #{release_root}/bin/#{appname} ]]; then
      (cd #{release_root} && tar zxfv nameui.tar.gz)
    fi

    #{release_root}/bin/#{appname} $@
    """
    |> write!("./bin/run/rel")


    """
    #!/bin/bash

    VERSION=$1
    RUNNING=$(./bin/run/rel ping)

    if [[ "$RUNNING" == "pong" ]]; then
      ./bin/run/rel upgrade $VERSION
    else
     ./bin/run/rel start
    fi
    """
    |> write!("./bin/run/launch")

    """
    #!/bin/bash
    bin/#{appname} rpc Elixir.#{module_name}.ReleaseTasks clear_cache
    """
    |> write!("./rel/commands/clear_cache")

    """
    #!/bin/bash
    bin/#{appname} rpc Elixir.#{module_name}.ReleaseTasks migrate
    """
    |> write!("./rel/commands/migrate")

    """
    #!/bin/bash
    ./bin/package/prerelease && \\
      iex -S mix phx.server
    """
    |> write!("./bin/run/debug")


    [
      "./bin/package/prerelease",
      "./bin/package/release",
      "./bin/package/retain",
      "./bin/run/rel",
      "./bin/run/launch",
      "./bin/run/debug",
      "./rel/commands/clear_cache",
      "./rel/commands/migrate",
    ]
    |> Enum.each(fn filename ->
         :ok = filename
               |> Path.expand
               |> File.chmod(0o755)
       end)

    IO.puts "Installed several release scripts into ./bin/run and ./bin/package"
    IO.puts "To enable ./rel/commands/clear_cache and ./rel/commands/migrate to be"
    IO.puts "part of the release, then ensure you update your ./rel/config.exs with:"
    IO.puts ""
    IO.puts ""

    example = """
    release :#{appname} do
      ...
      set commands: [
        "clear_cache": "rel/commands/clear_cache"
        "migrate": "rel/commands/migrate"
      ]
    end
    """

    IO.puts example
    IO.puts ""


  end

  defp write!(content, relative_name) do
    File.write!(relative_name |> Path.expand, content)
  end

end