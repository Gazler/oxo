# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :oxo,
  ecto_repos: [Oxo.Repo]

# Configures the endpoint
config :oxo, Oxo.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8z7EmlxaMD01MZLyNKnfjlprUVYg4TcAh2Ng6BXMIJpZmLdA+ZV14RwLFRl39w/T",
  render_errors: [view: Oxo.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Oxo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
  config :phoenix, :generators,
  binary_id: true


config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "MyApp",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "UAWyG3pSFjCsv9nRR+5Ms2TT42CINeeUFQr9g3iOCgkO9btWiTnm8G7ep8qhikcn",
  serializer: Oxo.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
