defmodule Mix.Tasks.Version.Up do
  use Mix.Task

  alias Mix.Tasks.Version

  @shortdoc "Inc to next version, and commit changes to git"
  def run(mode) do
    next_version = Version.Inc.run(mode)
    updated_version = Version.Current.calc(mode)

    if (next_version == updated_version) do
      IO.puts "Committing updates to git"
      repo = Git.new "."
      {:ok, _} = Git.add repo, ["mix.exs", "README.md"]
      {:ok, output} = Git.commit repo, ["-m", "v#{updated_version}"]
      IO.puts output
    else
      IO.puts "Unable to update version, stopping task. Sorry we couldn't automate better :-("
    end
    updated_version
  end

end