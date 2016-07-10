defmodule Seblog.AdminController do
  use Seblog.Web, :controller

  alias Seblog.Admin

  plug :scrub_params, "admin" when action in [:create, :update]

  def index(conn, _params) do
    admins = Repo.all(Admin)
    render(conn, "index.html", admins: admins)
  end

  def new(conn, _params) do
    changeset = Admin.changeset(%Admin{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"admin" => admin_params}) do
    changeset = Admin.registration_changeset(%Admin{}, admin_params)

    case Repo.insert(changeset) do
      {:ok, _admin} ->
        conn
        |> put_flash(:info, "Admin created successfully.")
        |> redirect(to: admin_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    admin = Repo.get!(Admin, id)
    render(conn, "show.html", admin: admin)
  end

  def edit(conn, %{"id" => id}) do
    admin = Repo.get!(Admin, id)
    changeset = Admin.changeset(admin)
    render(conn, "edit.html", admin: admin, changeset: changeset)
  end

  def update(conn, %{"id" => id, "admin" => admin_params}) do
    admin = Repo.get!(Admin, id)
    changeset = Admin.registration_changeset(admin, admin_params)

    case Repo.update(changeset) do
      {:ok, admin} ->
        conn
        |> put_flash(:info, "Admin updated successfully.")
        |> redirect(to: admin_path(conn, :show, admin))
      {:error, changeset} ->
        render(conn, "edit.html", admin: admin, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    admin = Repo.get!(Admin, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(admin)

    conn
    |> put_flash(:info, "Admin deleted successfully.")
    |> redirect(to: admin_path(conn, :index))
  end
end
