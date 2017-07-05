defmodule VersionTasks.Mixfile do
  use Mix.Project

  @name    :version_tasks
  @version "0.1.0"

  @deps [
    # { :earmark, ">0.1.5" },                      
    # { :ex_doc,  "1.2.3", only: [ :dev, :test ] }
    # { :my_app:  path: "../my_app" },
  ]
  
  # ------------------------------------------------------------
  
  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= 1.4.5",
      deps:    @deps,
      build_embedded:  in_production,
    ]
  end

  def application do
    [
      extra_applications: [         # built-in apps that need starting    
        :logger
      ], 
    ]
  end

end
