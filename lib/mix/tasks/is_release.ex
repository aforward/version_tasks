defmodule Mix.Tasks.Version.IsRelease do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.{Current, LastCommit, Name}

  @shortdoc "Return the name (major|minor|patch) of the version if this is a release, nothing otherwise"
  def run(_) do
    calc() |> IO.puts
  end

  def calc() do
    if "v#{Current.calc}" == LastCommit.calc do
      Name.calc
    else
      ""
    end
  end

end