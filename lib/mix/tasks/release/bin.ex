defmodule Mix.Tasks.Release.Bin do
  use Mix.Task

  @shortdoc "OBSOLETE... please refer to `mix version.bin.run`"
  def run(args) do
    IO.puts("OBSOLETE... please refer to `mix version.bin.run`")
    Mix.Tasks.Version.Bin.Release.run(args)
  end
end
