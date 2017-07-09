# VersionTasks

Provides an opinionated, but rational, set of mix tools for managing
version numbers for your Elixir project using the following scheme.

```
Major.Minor.Patch
```

You decide what each version number means, whether it's [semantic
versionning](http://semver.org/), [Spec-ulation from Rich Hickey](https://www.youtube.com/watch?v=oyLBGkS5ICk), or any other scheme.

## Installation

```elixir
@deps [
  version_tasks: "~> 0.3.1"
]
```

## Usage

A set of Mix Tasks for managing your version numbers

### Information Tasks

The following tasks just report back information about your project
without actually changing it.

Here's the basic usage

    MIX_QUIET=1 mix version.<current|inc|next|tag|up>

Notice the MIX_QUIET=1, this is important if you want to use these
scripts in other scripts and only get the answer back, not the additional
debugging outputs.

The examples below will omit the `MIX_QUIET=1`for brevity.

#### mix version.current

To retrieve the current version of your application, run

    mix version.current

The call back returns the current version of your project, for example

    1.2.3

This is based on your mix.exs file.

#### mix version.next

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

### Local Editing Tasks

The following tasks will edit your local files, but will not commit or push any of those changes.

#### mix version.inc

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

### Git Interaction Tasks

These next set of tasks will commit to your local repository and/or push to your local repository.

#### mix version.up

Upgrade the version number on your project and commit the changes files to your local git repository.

    mix version.up <major|minor|patch>?

#### mix version.tag

Following the `version.up`, we can tag and push the changes to your remote branch.

    mix version.tag

This will tag your repo with `vMajor.Minor.Patch` and push the tag to your remote branch.

### Publishing To Hex

Before you can use this task, you need to ensure you have registered with hex directly, you
can do this from the command line with

    mix hex.user register

Here's a script to upgrade your package on hex

    mix do version.up, version.tag, test, hext.publish

## License

MIT License

----
Created:  2017-07-05Z
