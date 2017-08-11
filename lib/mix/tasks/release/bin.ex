defmodule Mix.Tasks.Release.Bin do
  use Mix.Task

  @shortdoc "Initialize and create 'bin/run' helper scripts for managing releases"
  def run(_) do

    Mix.Task.run("release.init", [])

    :ok = "./bin/run" |> Path.expand |> File.mkdir_p!

    appname = Mix.Project.config[:app]
    module_name = appname |> Atom.to_string |> Macro.camelize


    """
    #!/bin/bash
    source ./bin/env && \\
      _build/prod/rel/#{appname}/bin/#{appname} console
    """
    |> write!("./bin/run/console")

    """
    #!/bin/bash
    source ./bin/env && \\
      _build/prod/rel/#{appname}/bin/#{appname} start
    """
    |> write!("./bin/run/daemon")

    """
    #!/bin/bash
    source ./bin/env && \\
      _build/prod/rel/#{appname}/bin/#{appname} foreground $1
    """
    |> write!("./bin/run/foreground")

    """
    #!/bin/bash
    source ./bin/env && \\
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
    source ./bin/env && \\
      _build/prod/rel/#{appname}/bin/#{appname} upgrade $1 && \\
      ./bin/run/rel rpc Elixir.#{module_name}.Release clear_cache
    """
    |> write!("./bin/run/upgrade")

    ["console"] #, "daemon", "downgrade", "foreground", "rel", "upgrade"]
    |> Enum.each(fn filename ->
         :ok = "./bin/run/#{filename}"
               |> Path.expand
               |> File.chmod(0o755)
       end)

    IO.puts "Installed several release scripts into ./bin/run"
  end

  defp write!(content, relative_name) do
    File.write!(relative_name |> Path.expand, content)
  end

end