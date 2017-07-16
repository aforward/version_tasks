defmodule Mix.Tasks.Githooks.Hexup do
  use Mix.Task

  @shortdoc "Install a githook to run mix hex.publish on a new release"
  def run(_), do: VersionTasks.run("./bin/githooks/hexpublish")

end