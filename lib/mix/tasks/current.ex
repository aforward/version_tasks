defmodule Mix.Tasks.Version.Current do
  use Mix.Task
  use VersionTasks.FnExpr

  @shortdoc "The current version of your project (e.g v0.9.1)"
  def run(args) do
    args
    |> calc
    |> IO.puts
  end

  @shortdoc "Calculate the current version"
  def calc(_) do
    "mix.exs"
    |> File.read
    |> invoke(fn ({:ok, content}) -> content end)
    |> String.split("\n")
    |> Enum.map(&find_version/1)
    |> Enum.reject(&is_nil/1)
    |> first
  end

  defp find_version(line) do
    find_version(:variable, line) || find_version(:inline, line)
  end

  defp find_version(:variable, line) do
    case Regex.run(~r{@version \"(.*)\"}, line) do
      nil -> nil
      [_, version] -> version
    end
  end

  defp find_version(:inline, line) do
    case Regex.run(~r{version: \"(.*)\"}, line) do
      nil -> nil
      [_, version] -> version
    end
  end

  defp first(list) do
    case Enum.fetch(list, 0) do
      {:ok, val} -> val
      :error -> nil
    end
  end

end