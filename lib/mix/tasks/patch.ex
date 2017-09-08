defmodule Mix.Tasks.Version.Patch do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.Current

  @shortdoc "Return patch number (so return '3' for version '1.2.3'"
  def run(_) do
    calc() |> IO.puts
  end

  def calc(), do: calc(Current.calc)
  def calc(version) do
    version
    |> String.split(".")
    |> name
  end

  defp name([_, _, patch]), do: patch
  defp name(_), do: ""

end