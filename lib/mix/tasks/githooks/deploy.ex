defmodule Mix.Tasks.Githooks.Deploy do
  use Mix.Task

  @shortdoc "Install a githook to run ./bin/deploy on a new release"
  def run([]), do: run(["bin/deploy"])
  def run([deploy_filename]) do
    post_commit_filename = ".git/hooks/post-commit"
    content = """
#!/bin/bash

if [ "$(MIX_QUIET=true mix version.is_release)" != "" ]; then
  ./bin/deploy
else
  echo "Continue making the app awesome."
fi
    """
    File.write!(post_commit_filename, content)
    :ok = File.chmod(post_commit_filename, 0o755)

    unless File.exists?(deploy_filename) do
      deploy_filename |> Path.dirname |> Path.expand |> File.mkdir_p!
      content = """
#!/bin/bash

VERSION=$(MIX_QUIET=1 mix version.current)
echo "================="
echo "DEPLOYING $VERSION"
echo "Based on script in #{deploy_filename}"
echo "By default it does nothing but runs your tests
echo "and tags your release.  So please update with
echo "what you need to do"
echo "================="
mix test && \\
  mix version.tag
      """
      File.write!(deploy_filename, content)
      :ok = File.chmod(deploy_filename, 0o755)
    end

    IO.puts "Installed #{post_commit_filename}"
    IO.puts "which will run #{deploy_filename}"
    IO.puts "after a 'mix version.up'"

    post_commit_filename
  end

end