defmodule Mix.Tasks.Githooks.Hexup do
  use Mix.Task

  @shortdoc "Install a githook to run mix hex.publish on a new release"
  def run([]), do: run([""])
  def run([passphrase]) do
    filename = ".git/hooks/post-commit"
    content = """
#!/bin/bash
MESSAGE=$(git log --format=%B -n 1 HEAD)
VERSION=$(echo $MESSAGE | grep "v[0-9]\\{1,\\}\\.[0-9]\\{1,\\}\\.[0-9]\\{1,\\}")
if [ "$VERSION" != "" ]; then
  echo "================="
  echo "HEX PUBLISH $VERSION"
  echo "================="
  mix test && \
    mix version.tag && \
    mix hex.publish <<EOF
#{passphrase}
Y
EOF
else
  echo "Continue making the app awesome."
fi
    """
    File.write!(filename, content)
    :ok = File.chmod(filename, 0o755)
    IO.puts "Installed #{filename}"
    IO.puts "to automatically 'mix test && mix version.tag && mix hex.publish'"
    IO.puts "after a 'mix version.up'"
    filename
  end

end