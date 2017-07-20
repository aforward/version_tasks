defmodule Mix.Tasks.Version.Current do
  use Mix.Task

  @shortdoc "The current version of your project"
  def run(args) do
    args
    |> calc
    |> IO.puts
  end

  @shortdoc "Calculate the current version"
  def calc(_), do: Mix.Project.config[:version]

end