defmodule Mix.Tasks.Release.Bin do
  use Mix.Task

  @shortdoc "Initialize and create 'bin/run' helper scripts for managing releases"
  def run([]), do: run([nil])
  def run([release_root]) do

    Mix.Task.run("release.init", [])

    [
      "./bin/run",
      "./bin/package",
    ]
    |> Enum.each(fn dirname ->
         :ok = dirname |> Path.expand |> File.mkdir_p!
       end)

    appname = Mix.Project.config[:app]
    default_root = "/src/#{appname}rel"
    release_root = release_root || default_root
    module_name = appname |> Atom.to_string |> Macro.camelize


    """
    defmodule #{module_name}.Release do

      @doc\"""
      Distillery upgrades were not (for me anyway) clearning the assets
      cache, so this called after an upgrade using RPC.

          ./bin/run/rel rpc #{module_name}.Release clear_cache

      This was based on help from
      https://github.com/bitwalker/exrm/issues/206
      \"""
      def clear_cache do
        Phoenix.Config.clear_cache #{module_name}.Web.Endpoint
        Phoenix.Endpoint.Supervisor.warmup #{module_name}.Web.Endpoint
      end

    end
    """
    |> write!("./lib/#{appname}/release.ex")


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

    if [[ ! -e #{release_root}/.git ]]; then
      (cd #{release_root} && git init)
    fi

    mkdir -p ${REL_ROOT}/releases/${VERSION}

    cp ./_build/prod/rel/#{appname}/releases/${VERSION}/#{appname}.tar.gz ${REL_ROOT}/releases/${VERSION}/#{appname}.tar.gz
    (cd ${REL_ROOT} && \
     ln -sf releases/${VERSION}/#{appname}.tar.gz #{appname}.tar.gz && \
     git add -f releases/${VERSION}/#{appname}.tar.gz && \
     git add #{appname}.tar.gz
     git commit -m "v${VERSION}" && \
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

    VERISON=$1
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
    ./bin/run/rel rpc Elixir.#{module_name}.Release clear_cache
    """
    |> write!("./bin/run/clear_cache")

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
    ]
    |> Enum.each(fn filename ->
         :ok = filename
               |> Path.expand
               |> File.chmod(0o755)
       end)

    IO.puts "Installed several release scripts into ./bin/run and ./bin/package"
  end

  defp write!(content, relative_name) do
    File.write!(relative_name |> Path.expand, content)
  end

end