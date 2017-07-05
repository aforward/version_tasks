defmodule Mix.Tasks.Version.Next do
  use Mix.Task

  @shortdoc "The next version of your project, provide major, minor or patch as input"
  def run(mode), do: VersionTasks.run("./bin/version/next #{mode}")

end