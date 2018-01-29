defmodule Mix.Tasks.Version.Inc do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version

  @shortdoc "Inc to the next (major|minor|patch) version of your project"
  def run(mode) do
    current = Version.Current.calc(mode)
    next = Version.Next.calc(mode)

    IO.puts("Updating mix.exs from #{current} to #{next}")

    update_file("mix.exs", current, next, &update_mix_version/3)
    update_file("README.md", current, next, &update_readme_version/3)
    next
  end

  defp update_file(filename, current, next, update_fn) do
    if File.exists?(filename) do
      IO.puts("  -- Updating #{filename}")

      filename
      |> File.read()
      |> invoke(fn {:ok, content} -> content end)
      |> String.split("\n")
      |> Enum.map(fn line -> update_fn.(line, current, next) end)
      |> Enum.join("\n")
      |> invoke(fn content -> File.write!(filename, content) end)
    else
      IO.puts("  -- Skipping missing file #{filename}")
    end
  end

  defp update_mix_version(line, current, next) do
    line
    |> String.replace("@version \"#{current}\"", "@version \"#{next}\"")
    |> String.replace("version: \"#{current}\"", "version: \"#{next}\"")
  end

  defp update_readme_version(line, current, next) do
    line
    |> String.replace("~> #{current}", "~> #{next}")
  end
end
