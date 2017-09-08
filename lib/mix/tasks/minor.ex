defmodule Mix.Tasks.Version.Minor do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.Current

  @shortdoc "Return minor number (so return '2' for version '1.2.3'"
  def run(_) do
    calc() |> IO.puts
  end

  def calc(), do: calc(Current.calc)
  def calc(version) do
    version
    |> String.split(".")
    |> name
  end

  defp name([_, minor, _]), do: minor
  defp name(_), do: ""

end