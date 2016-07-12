defmodule Seblog.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Seblog.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import Seblog.Router.Helpers

      # The default endpoint for testing
      @endpoint Seblog.Endpoint

      alias Seblog.Admin

      @default_opts [
        store: :cookie,
        key: "foobar",
        encryption_salt: "encrypted cookie salt",
        signing_salt: "signing salt",
        log: false
      ]

      @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

      setup do
        Repo.insert!(%Admin{:email => "test@example.com", :password_hash => Comeonin.Bcrypt.hashpwsalt("test")})
        conn = build_conn() 
        |> Plug.Session.call(@signing_opts)
        |> fetch_session
        {:ok, conn} = Seblog.Auth.login_by_email_and_pass(conn, "test@example.com", "test", 
                                                 repo: Repo)
        Guardian.Plug.current_resource(conn)

        %{
          conn: conn
        }
      end

    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Seblog.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Seblog.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
