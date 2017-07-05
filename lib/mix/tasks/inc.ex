defmodule Mix.Tasks.Version.Inc do
  use Mix.Task

  @shortdoc "Increment to the next version of your project, provide major, minor or patch as input"
  def run(mode), do: VersionTasks.run("./bin/version/inc #{mode}")

end