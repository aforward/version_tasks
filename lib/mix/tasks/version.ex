defmodule Mix.Tasks.Version do
  use Mix.Task

  alias VersionTasks.Shell

  @shortdoc "Learn more about the available version tasks"
  def run(_) do
    Shell.info "version_tasks v" <> VersionTasks.version
    Shell.info "version_tasks is a set of helper mix tasks to manange your projects version"
    Shell.newline

    Shell.info "Available version tasks:"
    Shell.newline
    # Run `mix help --search version.`, and
    # Run `mix help --search githooks.` to get this output
    # and paste here

    Shell.info "mix version.bin.db      # Create 'bin/db' helper scripts for managing database backups"
    Shell.info "mix version.bin.release # Initialize and create some 'bin' helper scripts for managing releases"
    Shell.info "mix version.current     # Calculate the current version"
    Shell.info "mix version.inc         # Inc to the next (major|minor|patch) version of your project"
    Shell.info "mix version.is_release  # Return the name (major|minor|patch) of the version if this is a release, nothing otherwise"
    Shell.info "mix version.last_commit # Calculate the last git commit message"
    Shell.info "mix version.name        # Return the name (major|minor|patch) of this version"
    Shell.info "mix version.next        # The next version (e.g v0.9.2)"
    Shell.info "mix version.tag         # Git tag your project (e.g. v1.2.3)"
    Shell.info "mix version.up          # Inc to next version, and commit changes to git"
    Shell.info "mix githooks.hexup      # Install a githook to run mix hex.publish on a new release"

    Shell.newline

    Shell.info "Further information can be found here:"
    Shell.info "  -- https://hex.pm/packages/version_tasks"
    Shell.info "  -- https://github.com/aforward/version_tasks"
    Shell.newline

  end

end