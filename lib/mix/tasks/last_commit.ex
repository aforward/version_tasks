defmodule Mix.Tasks.Version.LastCommit do
  use Mix.Task
  use VersionTasks.FnExpr

  @shortdoc "Return the last git commit message"
  def run(args) do
    args
    |> calc
    |> IO.puts
  end

  @shortdoc "Calculate the last git commit message"
  def calc(_ \\ nil) do
    "."
    |> Git.new
    |> Git.log(["--format=%B", "-n 1", "HEAD"])
    |> invoke(fn {:ok, output} -> output end)
    |> String.trim
  end

end