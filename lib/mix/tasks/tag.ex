defmodule Mix.Tasks.Version.Tag do
  use Mix.Task

  @shortdoc "Tag your project with the current version"
  def run(_) do
    shell("git tag \"v#{Mix.Project.config[:version]}\"")
    shell("git push")
    shell("git push --tag")
  end

  def shell(script) do
    Application.put_env(:porcelain, :driver, Porcelain.Driver.Basic)
    {:ok, _started} = Application.ensure_all_started(:porcelain)
    Porcelain.shell(script, out: IO.stream(:stdio, :line))
  end

end