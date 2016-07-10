
defmodule Seblog.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Plug.Conn
  def login(conn, admin) do
    conn
    |> Guardian.Plug.sign_in(admin, :access)
  end
  def login_by_email_and_pass(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    admin = repo.get_by(Seblog.Admin, email: email)
    cond do
      admin && checkpw(given_pass, admin.password_hash) ->
        {:ok, login(conn, admin)}
      admin ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end
end