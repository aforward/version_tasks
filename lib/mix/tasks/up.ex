defmodule Mix.Tasks.Version.Next do
  use Mix.Task

  @shortdoc "Update your project to the next version, and commit the new files, provide major, minor or patch as input"
  def run(mode), do: VersionTasks.run("./bin/version/up #{mode}")

end