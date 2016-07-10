defmodule Seblog.ViewHelper do
  def current_admin(conn), do: Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
end