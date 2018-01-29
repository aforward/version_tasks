defmodule Mix.Tasks.Githooks.Hexup do
  use Mix.Task

  @shortdoc "Install a githook to run mix hex.publish on a new release"
  def run([]), do: run([""])

  def run([passphrase]) do
    filename = ".git/hooks/post-commit"

    content = """
    #!/bin/bash
    if [ "$(MIX_QUIET=true mix version.is_release)" != "" ]; then
      echo "================="
      echo "HEX PUBLISH $VERSION"
      echo "================="
      mix test && \\
        mix version.tag && \\
        mix hex.publish <<EOF
    Y
    #{passphrase}
    EOF
    else
      echo "Continue making the app awesome."
    fi
    """

    File.write!(filename, content)
    :ok = File.chmod(filename, 0o755)
    IO.puts("Installed #{filename}")
    IO.puts("to automatically 'mix test && mix version.tag && mix hex.publish'")
    IO.puts("after a 'mix version.up'")
    filename
  end
end
