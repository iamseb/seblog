defmodule Seblog.ThemeControllerTest do
  use Seblog.ConnCase

  alias Seblog.Theme
  @valid_attrs %{active: true, name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, theme_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing themes"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, theme_path(conn, :new)
    assert html_response(conn, 200) =~ "New theme"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, theme_path(conn, :create), theme: @valid_attrs
    assert redirected_to(conn) == theme_path(conn, :index)
    assert Repo.get_by(Theme, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, theme_path(conn, :create), theme: @invalid_attrs
    assert html_response(conn, 200) =~ "New theme"
  end

  test "shows chosen resource", %{conn: conn} do
    theme = Repo.insert! %Theme{}
    conn = get conn, theme_path(conn, :show, theme)
    assert html_response(conn, 200) =~ "Show theme"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, theme_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    theme = Repo.insert! %Theme{}
    conn = get conn, theme_path(conn, :edit, theme)
    assert html_response(conn, 200) =~ "Edit theme"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    theme = Repo.insert! %Theme{}
    conn = put conn, theme_path(conn, :update, theme), theme: @valid_attrs
    assert redirected_to(conn) == theme_path(conn, :show, theme)
    assert Repo.get_by(Theme, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    theme = Repo.insert! %Theme{}
    conn = put conn, theme_path(conn, :update, theme), theme: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit theme"
  end

  test "deletes chosen resource", %{conn: conn} do
    theme = Repo.insert! %Theme{}
    conn = delete conn, theme_path(conn, :delete, theme)
    assert redirected_to(conn) == theme_path(conn, :index)
    refute Repo.get(Theme, theme.id)
  end
end
