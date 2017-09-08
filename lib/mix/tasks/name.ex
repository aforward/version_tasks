defmodule Mix.Tasks.Version.Name do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.Current

  @shortdoc "Return the name (major|minor|patch) of this version"
  def run(_) do
    calc() |> IO.puts
  end

  def calc(), do: calc(Current.calc)
  def calc(version) do
    version
    |> String.split(".")
    |> name
  end

  defp name([_, "0", "0"]), do: :major
  defp name([_, _, "0"]), do: :minor
  defp name(_), do: :patch

end