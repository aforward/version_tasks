defmodule Mix.Tasks.Version.Rc do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.Current

  @shortdoc "Return RC number (so return '1' for version '1.2.3-rc1'"
  def run(_) do
    calc() |> IO.puts()
  end

  def calc(), do: calc(Current.calc())

  def calc(version) do
    version
    |> String.split(".")
    |> name
  end

  defp name([_, _, patch]) do 
    case Integer.parse(patch) do
      {_patch_val, ""} -> "0"
      {_patch_val, "-rc" <> existing_rc} -> existing_rc
    end
  end
  defp name(_), do: ""
end
