# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :geo_location_service,
  ecto_repos: [GeoLocationService.Repo]

# Configures the endpoint
config :geo_location_service, GeoLocationServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CZtk08QapTpjkF31yrT1XYwNePLBulR/XH5HYL3OEkvHsSxMMxbtsCMCB1nh9arw",
  render_errors: [view: GeoLocationServiceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GeoLocationService.PubSub,
  live_view: [signing_salt: "9okByi5t"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
