defmodule Mix.Tasks.Version.Bin.Ff do
  use Mix.Task

  @shortdoc "Add a FeatureFlags (FF) GenServer with release helper scripts to enable/disable them"
  def run(_) do
    [
      "./rel/commands"
    ]
    |> Enum.each(fn dirname ->
      :ok = dirname |> Path.expand() |> File.mkdir_p!()
    end)

    appname = Mix.Project.config()[:app]
    module_name = appname |> Atom.to_string() |> Macro.camelize()

    """
    defmodule #{module_name}.FeatureFlags do
      use GenServer

      alias GenServer, as: GS
      alias #{module_name}.FeatureFlags, as: W

      ### Public API

      def start_link(), do: {:ok, _pid} = GS.start_link(__MODULE__, [], name: __MODULE__)

      def reset, do: GS.call(W, :reset)
      def enable(flag), do: GS.call(W, {:enable, flag |> clean_flag})
      def disable(flag), do: GS.call(W, {:disable, flag |> clean_flag})
      def remove(flag), do: GS.call(W, {:remove, flag |> clean_flag})

      def enabled?(flag, default_answer \\\\ false), do: GS.call(W, {:enabled?, flag |> clean_flag, default_answer})
      def disabled?(flag, default_answer \\\\ true), do: GS.call(W, {:disabled?, flag |> clean_flag, default_answer})
      def available?(flag), do: GS.call(W, {:available?, flag |> clean_flag})

      ### Server Callbacks

      def init(_) do
        {:ok, %{}}
      end

      def handle_call(:reset, _from, state) do
        {:reply, state, %{}}
      end

      def handle_call({:enable, flag}, _from, state) do
        {:reply, :ok, state |> Map.put(flag, true)}
      end

      def handle_call({:disable, flag}, _from, state) do
        {:reply, :ok, state |> Map.put(flag, false)}
      end

      def handle_call({:remove, flag}, _from, state) do
        state
        |> Map.get(flag)
        |> (&{:reply, &1, Map.delete(state, flag)}).()
      end

      def handle_call({:enabled?, flag, default_answer}, _from, state) do
        check_flag(state, flag, true, default_answer)
      end

      def handle_call({:disabled?, flag, default_answer}, _from, state) do
        check_flag(state, flag, false, default_answer)
      end

      def handle_call({:available?, flag}, _from, state) do
        {:reply, Map.has_key?(state, flag), state}
      end

      def clean_flag(flag) when is_atom(flag), do: flag
      def clean_flag(flag) when is_binary(flag), do: String.to_atom(flag)
      def clean_flag(flag) when is_list(flag), do: flag |> to_string |> String.to_atom
      def clean_flag(flag), do: flag

      def check_flag(state, flag, compare_to, default_if_missing) do
        state
        |> Map.has_key?(flag)
        |> (fn
             true -> Map.get(state, flag) == compare_to
             false -> default_if_missing
           end).()
        |> (&{:reply, &1, state}).()
      end

    end
    """
    |> write!("./lib/#{appname}/feature_flags.ex")

    """
    #!/bin/bash
    bin/#{appname} rpc Elixir.#{module_name}.FeatureFlags enable "$1"
    """
    |> write!("./rel/commands/enable")

    """
    #!/bin/bash
    bin/#{appname} rpc Elixir.#{module_name}.FeatureFlags disable "$1"
    """
    |> write!("./rel/commands/disable")

    [
      "./rel/commands/enable",
      "./rel/commands/disable"
    ]
    |> Enum.each(fn filename ->
      :ok =
        filename
        |> Path.expand()
        |> File.chmod(0o755)
    end)

    IO.puts("Installed several release scripts into ./bin/run and ./bin/package")
    IO.puts("To enable ./rel/commands/enable and ./rel/commands/disable to be")
    IO.puts("part of the release, then ensure you update your ./rel/config.exs with:")
    IO.puts("")
    IO.puts("")

    example = """
    release :#{appname} do
      ...
      set commands: [
        "enable": "rel/commands/enable",
        "disable": "rel/commands/disable"
      ]
    end
    """

    IO.puts(example)
    IO.puts("")
    IO.puts("To enable a feature flag 'brb' (for example) you would run the following:")
    IO.puts("    ./bin/#{appname} enable brb")
    IO.puts("")
    IO.puts("To later disable that flag you would run the following:")
    IO.puts("    ./bin/#{appname} disable brb")
    IO.puts("")
  end

  defp write!(content, relative_name) do
    File.write!(relative_name |> Path.expand(), content)
  end
end
