defmodule Seblog.SessionController do

    use Seblog.Web, :controller

    def new(conn, _) do
        render conn, "new.html"
    end


    def create(conn, %{"session" => %{"email" => admin, 
                                      "password" => pass}}) do
      case Seblog.Auth.login_by_email_and_pass(conn, admin, pass, 
                                             repo: Repo) do
        {:ok, conn} ->
          logged_in_admin = Guardian.Plug.current_resource(conn)
          conn
          |> put_flash(:info, "Logged in.")
          |> redirect(to: admin_path(conn, :show, logged_in_admin))
        {:error, _reason, conn} ->
          conn
          |> put_flash(:error, "Could not validate the user/password entered.")
          |> render("new.html")
       end
    end


  def delete(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end

end