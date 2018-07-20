defmodule Mix.Tasks.Version do
  use Mix.Task

  alias VersionTasks.Shell

  @moduledoc """
  version_tasks #{VersionTasks.version()}

  version_tasks is a set of helper mix tasks to manange your projects version

  Available version tasks:

  Tasks related to generating scripts (and elixir code) to help manage your app.
      mix version.bin.db
      mix version.bin.ff
      mix version.bin.release

  Tasks related to managing the version of your library / component / system.
      mix version.current
      mix version.inc
      mix version.is_release
      mix version.last_commit
      mix version.name
      mix version.next

  Tasks related to GIT operations
      mix version.tag
      mix version.untag
      mix version.up

  Tasks related to GIT hooks
      mix githooks.hexup
      mix githooks.deploy

  For more details, you can run

      mix help <taskname>

  For example,

      mix help version.bin.db

  Further information can be found here:

    * https://hex.pm/packages/version_tasks
    * https://github.com/aforward/version_tasks

  """

  @shortdoc "Learn more about the available version tasks"
  def run(_) do
    Shell.info("version_tasks v" <> VersionTasks.version())
    Shell.info("version_tasks is a set of helper mix tasks to manange your projects version")
    Shell.newline()

    Shell.info("Available version tasks:")
    Shell.newline()
    # Run `mix help --search version.`, and
    # Run `mix help --search githooks.` to get this output
    # and paste here

    Shell.info(
      "mix version.bin.db      # Create 'bin/db' helper scripts for managing database backups"
    )

    Shell.info(
      "mix version.bin.ff      # Add a FeatureFlags (FF) GenServer with release helper scripts to enable/disable them"
    )

    Shell.info(
      "mix version.bin.release # Initialize and create some 'bin' helper scripts for managing releases"
    )

    Shell.info("mix version.current     # Calculate the current version")

    Shell.info(
      "mix version.inc         # Inc to the next (major|minor|patch) version of your project"
    )

    Shell.info(
      "mix version.is_release  # Return the name (major|minor|patch) of the version if this is a release, nothing otherwise"
    )

    Shell.info("mix version.last_commit # Calculate the last git commit message")
    Shell.info("mix version.name        # Return the name (major|minor|patch) of this version")
    Shell.info("mix version.next        # The next version (e.g v0.9.2)")
    Shell.info("mix version.tag         # Git tag your project (e.g. v1.2.3)")
    Shell.info("mix version.untag       # Remove the git tag from your repo (e.g. v1.2.3)")
    Shell.info("mix version.up          # Inc to next version, and commit changes to git")

    Shell.info(
      "mix githooks.hexup      # Install a githook to run mix hex.publish on a new release"
    )

    Shell.info("mix githooks.deploy     # Install a githook to run ./bin/deploy on a new release")

    Shell.newline()

    Shell.info("Further information can be found here:")
    Shell.info("  -- https://hex.pm/packages/version_tasks")
    Shell.info("  -- https://github.com/aforward/version_tasks")
    Shell.newline()
  end
end
