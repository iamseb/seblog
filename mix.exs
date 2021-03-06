defmodule Seblog.Mixfile do
  use Mix.Project

  def project do
    [app: :seblog,
     version: "0.0.1",
     elixir: "~> 1.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Seblog, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext, :timex,
                    :phoenix_ecto, :postgrex, :ex_aws, :httpoison, :arc, :arc_ecto]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:postgrex, "~> 0.11.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:httpoison, "~> 0.9.0"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
     {:comeonin, "~> 2.5"},
     {:guardian, "~> 0.14.0"},
     {:earmark, "~> 1.0.0"},
     {:slugger, git: "https://github.com/h4cc/slugger"},
     {:arc, "~> 0.6.0"},
     {:arc_ecto, "~> 0.5.0"},
     {:sweet_xml, "~> 0.6.0"},
     {:ex_aws, "~> 1.0.0"}, # Required if using Amazon S3
     {:mogrify, "~> 0.3.2"},
     {:mailgun, git: "https://github.com/chrismccord/mailgun/"},
     {:html_sanitize_ex, "~> 1.0.0"},
     {:timex, "~> 3.0"}
    ]

  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate"], #, "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
