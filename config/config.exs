# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :seblog,
  ecto_repos: [Seblog.Repo]


# Configures the endpoint
config :seblog, Seblog.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "7JyRrsVsYB8izuJTJvgMfkbl45pYIIRefD2wOnzrhoIkNbJDLQzeigVGryThQc/O",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Seblog.PubSub,
           adapter: Phoenix.PubSub.PG2],
  site_name: "Seblog",
  site_title: "Words and pictures."

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :seblog, Seblog.CachedImage,
  cache_base: "img_cache",
  cache_widths: [tiny: 30, small: 200, medium: 400, large: 800, full: 1600]


config :seblog, Seblog.S3Image,
  cache_base: "img_cache",
  cache_widths: [tiny: 30, small: 200, medium: 400, large: 800, full: 1600]


config :arc,
  asset_host: "https://images.sebpotter.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"


# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: true

