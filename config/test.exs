use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :seblog, Seblog.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :seblog, Seblog.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "seblog_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

import_config "config.secret.exs"

config :guardian, Guardian,
  serializer: Seblog.TestGuardianSerializer