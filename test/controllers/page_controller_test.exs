defmodule Seblog.PageControllerTest do
  use Seblog.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Seb Potter"
  end
end
