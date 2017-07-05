defmodule Mix.Tasks.Version.Current do
  use Mix.Task

  @shortdoc "The current version of your project"
  def run(_), do: VersionTasks.run("./bin/version/current")

end