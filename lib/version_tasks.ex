defmodule VersionTasks do

  @moduledoc"""
  A set of Mix Tasks for managing your version numbers

  ## Information Tasks

  The following tasks just report back information about your project
  without actually changing it.

  Here's the basic usage

      MIX_QUIET=1 mix version.<current|inc|next|tag|up>

  Notice the MIX_QUIET=1, can sometimes be important if you are
  using this within a `dev` environment where additional debugging
  output might be included

  The examples below will omit the `MIX_QUIET=1`for brevity, and as
  it isn't strictly required.

  ### mix version.current

  To retrieve the current version of your application, run

      mix version.current

  The call back returns the current version of your project, for example

      1.2.3

  This is based on your mix.exs file.

  ### mix version.next

  To retrieve the _next_ version of your application, run

      mix version.next <major|minor|patch>?

  The default increment step is patch, here are a few examples from the version above

      mix version.next
      1.2.4

      mix version.next patch
      1.2.4

      mix version.next minor
      1.3.0

      mix version.next major
      2.0.0

  ### mix version.name

  After an upgrade, you might want to trigger additional actions, such as run tests
  create a release and deploy an update.  You can ask for the `name` of the version using:

      # For anything like X.0.0, that's a major release
      mix version.name
      major

      # For anything like X.Y.0, that's a minor release
      mix version.name
      minor

      # For all other releases, like X.Y.Z, that's a patch release
      mix version.name
      patch

  ### mix version.is_release

  This is the same as `mix version.name` with the exception that it will only return the
  version name *IF* the last commit was a version commit, which looks like `vX.Y.Z`.

      # If the last commit was `Doing something great`, then it returns nothing
      mix version.is_release

      # However, if the last commit was `v1.2.0`, then it returns `minor`
      mix version.is_release
      minor

  ### mix version.last_commit

  To help us trigger when a release has been requested, we are exposing the last commit
  message, this delegates to git and simply calls (`git log --format=%B -n 1 HEAD`)

      # Grab the last commit
      mix version.last_commit
      Simplify the database backup, to make restore easier

      # Hey, this commmit looks like a new release was commit
      mix version.last_commit
      v1.4.5

  ## Local Editing Tasks

  The following tasks will edit your local files, but will not commit or push any of those changes.

  ### mix version.inc

  Increment your project to the next version, this will update your mix.exs AND your README.md file.

      mix version.inc <major|minor|patch>?

  Your `mix.exs` MUST HAVE a variable named as follows for this to work

        @version "1.2.3"

  This is the default is based on a template from [Dave Thomas](https://pragdave.me/) with his `mix gen <template>`
  alternative to mix new.  [A video explaining mix gen and mix template](https://pragdave.me/blog/2017/04/18/elixir-project-generator.html?utm_content=buffera10cf&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer)

  And your `README.md` SHOULD HAVE an installation section as follows:

        @deps [
          your_app_name: "~> 1.2.3"
        ]

  ## Git Interaction Tasks

  These next set of tasks will commit to your local repository and/or push to your local repository.

  ### mix version.up

  Upgrade the version number on your project and commit the changes files to your local git repository.

      mix version.up <major|minor|patch>?

  ### mix version.tag

  Following the `version.up`, we can tag and push the changes to your remote branch.

      mix version.tag

  This will tag your repo with `vMajor.Minor.Patch` and push the tag to your remote branch.

  ## Publishing To Hex

  Before you can use this task, you need to ensure you have registered with hex directly, you
  can do this from the command line with

      mix hex.user register

  Here's a script to upgrade your package on hex

      mix version.up <major|minor|patch> && \\
        version.tag, && \\
        mix test && \\
        mix hex.publish

  I usually drop this in a `./bin/hexup` bash script in my project,
  as `mix test` needs the `MIX_ENV=test`, and you cannot combine
  updating the version number with `hex.publish` as it won't pick
  up the new version you just created.

  ## Auto publish to Hex.

  You can configure an automatic push to hex, but to do that you
  cannot have a passphrase associated with your key.

      mix hex.user passphrase

  And then you install a git hook which will install a post-commit
  hook

      mix githooks.hexup

  If you want to keep your passphrase, then it will be stored in plaintext
  inside your .git/hooks directory, simply call

      mix githooks.hexup <passphrase>

  Your passphrase should be different then your hex.pm password.

  ## Release Helper Functions

  THIS FEATURE IS IN BETA, AND NOT READY FOR PRIME TIME.

  If you are adventurous enough to use it, please send me feedback (raise an issue,
  push a pull request or contact me through GitHub)

  When creating releases (aka `mix release`), there are a few scripts that
  are handy to have around to start a console, or upgrade the release, etc.
  To install these scripts into your project, run

      mix release.bin <release_path>

  The `<release_path>` is the location where your releases will be stored.
  At present, it drops them into a local git repository, but going forward
  additional storage mechanism (e.g AWS S3) could be supported.

  The generated scripts call into three categories (and will be placed in
  3 directories):

      # These are scripts to help build and package your release
      ./bin/package

        + prerelease        # Prepare your release (compile, digest, etc)
        + release           # Create a release using distillery
        + retain            # Store the release in your `<release_path>`

      # These are scripts to help `run` your released app
      ./bin/run

        + debug             # Start your app based on compiles source (not a release)
        + launch            # Upgrade (if running) or start (if stopped) your application
        + rel               # Interact with your release (e.g. `<release_path>/bin/<appname>`)

      # These are scripts that can be deployed as custom commands
      # into your release
      ./rel/commands

        + clear_cache       # Clear the phoenix assets after a hot code swap
        + migrate           # Migrate all available Ecto repos

  Please note that Phoenix (at present), was not reloading the re-compiled static
  assets on an `upgrade`, so we also write a `&<AppModule>.ReleaseTasks.clear_cache/0` to
  deal with ensuring that javascript and CSS are properly available.

  We also expose `&<AppModule>.ReleaseTasks.migrate/0` to help migrate any configured
  ecto repoistories.  Plans to create if missing will be considered, but not yet available.

  These functions are available in

      ./lib/<appname>/release_tasks.ex.ex

  You will need to commit these files to you project.  If you edit them, please let
  me know (raise an issue, push a pull request or contact me through GitHub) as the
  changes might be relevant to others.

  """

  def version(), do: unquote(Mix.Project.config[:version])
  def elixir_version(), do: unquote(System.version)

end
