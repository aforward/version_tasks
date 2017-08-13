defmodule Mix.Tasks.Release.Bin do
  use Mix.Task

  @shortdoc "Initialize and create 'bin/run' helper scripts for managing releases"
  def run(_) do

    Mix.Task.run("release.init", [])

    [
      "./bin/run",
      "./bin/package",
    ]
    |> Enum.each(fn dirname ->
         :ok = dirname |> Path.expand |> File.mkdir_p!
       end)

    appname = Mix.Project.config[:app]
    module_name = appname |> Atom.to_string |> Macro.camelize


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
    _build/prod/rel/#{appname}/bin/#{appname} console
    """
    |> write!("./bin/run/console")

    """
    #!/bin/bash
    _build/prod/rel/#{appname}/bin/#{appname} start
    """
    |> write!("./bin/run/daemon")

    """
    #!/bin/bash
    _build/prod/rel/#{appname}/bin/#{appname} foreground $1
    """
    |> write!("./bin/run/foreground")

    """
    #!/bin/bash
    _build/prod/rel/#{appname}/bin/#{appname} $@
    """
    |> write!("./bin/run/rel")

    """
    defmodule #{module_name}.Release do

      @doc\"""
      EXRM upgrades were not (for me anyway) clearning the assets
      cache, so this called after an upgrade using RPC, something LexicalTracker.

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
    _build/prod/rel/#{appname}/bin/#{appname} upgrade $1 && \\
      ./bin/run/rel rpc Elixir.#{module_name}.Release clear_cache
    """
    |> write!("./bin/run/upgrade")

    """
    #!/bin/bash
    _build/prod/rel/#{appname}/bin/#{appname} downgrade $1
    """
    |> write!("./bin/run/downgrade")

    """
    #!/bin/bash
    ./bin/package/prerelease && \\
      mix phx.server
    """
    |> write!("./bin/run/debug")

    [
      "./bin/run/console",
      "./bin/run/daemon",
      "./bin/run/downgrade",
      "./bin/run/foreground",
      "./bin/run/rel",
      "./bin/run/upgrade",
      "./bin/run/debug",
      "./bin/package/prerelease",
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