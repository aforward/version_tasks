use Mix.Config

#     config(:version_tasks, key: :value)
#
# And access this configuration in your application as:
#
#     Application.get_env(:version_tasks, :key)
#
# Or configure a 3rd-party app:
#
#     config(:logger, level: :info)
#

# Example per-environment config:
#
#     import_config("#{Mix.env}.exs")
config :porcelain, driver: Porcelain.Driver.Basic