defmodule VersionTasks.Mixfile do
  use Mix.Project

  @app :version_tasks
  @git_url "https://github.com/aforward/version_tasks"
  @home_url @git_url
  @version "0.12.0"

  @deps [
    {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
    {:git_cli, "~> 0.2"},
    {:ex_doc, ">= 0.0.0", only: [:dev, :test]}
  ]

  @package [
    name: @app,
    description: "A suite of mix tasks for managing your libs version numbers with git and hex",
    files: ["lib", "mix.exs", "README*", "README*", "LICENSE*"],
    maintainers: ["Andrew Forward"],
    licenses: ["MIT"],
    links: %{"GitHub" => @git_url}
  ]

  @docs [
    extras: [
      "README.md": [title: "Overview"]
    ],
    main: "readme",
    homepage_url: @home_url,
    source_url: @git_url,
    source_ref: "v#{@version}",
    formatters: ["html"]
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @app,
      version: @version,
      elixir: "~> 1.11",
      name: "VersionTasks",
      build_embedded: in_production,
      start_permanent: in_production,
      package: @package,
      deps: @deps,
      docs: @docs
    ]
  end

  def application do
    [
      # built-in apps that need starting
      extra_applications: [
        :logger
      ]
    ]
  end
end
