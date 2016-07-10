ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Seblog.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Seblog.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Seblog.Repo)

