defmodule Mix.Tasks.Version.Major do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.Current

  @shortdoc "Return major number (so return '1' for version '1.2.3'"
  def run(_) do
    calc() |> IO.puts()
  end

  def calc(), do: calc(Current.calc())

  def calc(version) do
    version
    |> String.split(".")
    |> name
  end

  defp name([major, _, _]), do: major
  defp name(_), do: ""
end
