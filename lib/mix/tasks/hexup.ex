defmodule Mix.Tasks.Hex.Up do
  use Mix.Task

  @shortdoc "Update and push your hex project, provide major, minor or patch as input"
  def run(mode), do: VersionTasks.run("./bin/hexup #{mode}")

end