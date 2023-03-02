defmodule Mix.Tasks.Version.Next do
  use Mix.Task
  use VersionTasks.FnExpr
  alias Mix.Tasks.Version.Current

  @shortdoc "The next version (e.g v0.9.2)"
  def run(args) do
    args
    |> calc
    |> IO.puts()
  end

  def calc([]), do: calc(["patch"])

  def calc([mode]) do
    Current.calc()
    |> String.split(".")
    |> uptick(mode)
  end

  def uptick([major, minor, patch], "patch") do
    {new_val, ""} = Integer.parse(patch)
    "#{major}.#{minor}.#{new_val + 1}"
  end

  def uptick([major, minor, _patch], "minor") do
    {new_val, ""} = Integer.parse(minor)
    "#{major}.#{new_val + 1}.0"
  end

  def uptick([major, _minor, _patch], "major") do
    {new_val, ""} = Integer.parse(major)
    "#{new_val + 1}.0.0"
  end

  def uptick([major, minor, patch], "rc") do
    {major, ""} = Integer.parse(major)

    {major, patch, rc_patch} =
      case Integer.parse(patch) do
        {patch_val, ""} ->
          {major + 1, patch_val, "rc0"}

        {patch_val, "-rc" <> existing_rc} ->
          {rc_val, ""} = Integer.parse(existing_rc)
          {major, patch_val, "rc#{rc_val + 1}"}
      end

    "#{major}.#{minor}.#{patch}-#{rc_patch}"
  end
end
