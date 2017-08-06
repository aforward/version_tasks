defmodule Mix.Tasks.Version.Tag do
  use Mix.Task

  alias Mix.Tasks.Version

  @shortdoc "Git tag your project (e.g. v1.2.3)"
  def run(args) do
    current_version = Version.Current.calc(args)
    repo = Git.new "."
    {:ok, _} = Git.tag repo, ["v#{current_version}"]
    {:ok, output} = Git.push repo
    IO.puts output
    {:ok, output} = Git.push repo, ["--tag"]
    IO.puts output
    current_version
  end

end