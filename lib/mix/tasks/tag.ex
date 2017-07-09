defmodule Mix.Tasks.Version.Tag do
  use Mix.Task

  @shortdoc "Tag your project with the current version"
  def run(_), do: VersionTasks.run("./bin/version/tag")

end