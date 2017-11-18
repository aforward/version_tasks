defmodule Mix.Tasks.Version.Untag do
  use Mix.Task

  alias Mix.Tasks.Version

  @shortdoc "Remove the tag from your project (e.g. v1.2.3)"
  def run(args) do
    current_version = Version.Current.calc(args)
    repo = Git.new "."
    {:ok, output} = Git.tag repo, ["-d", "v#{current_version}"]
    IO.puts output
    {:ok, output} = Git.push repo, ["origin", ":refs/tags/v#{current_version}"]
    IO.puts output
    current_version
  end

end