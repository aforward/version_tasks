defmodule Mix.Tasks.Version.Current do
  use Mix.Task

  @shortdoc "The current version of your project"
  def run(_) do
    IO.puts(Mix.Project.config[:version])
  end

end