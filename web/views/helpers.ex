defmodule Seblog.ViewHelper do
  def current_admin(conn), do: Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def site_name(conn), do: Application.get_env(:seblog, Seblog.Endpoint)[:site_name]
  def site_title(conn), do: Application.get_env(:seblog, Seblog.Endpoint)[:site_title]
  def google_analytics(conn), do: Application.get_env(:seblog, Seblog.Endpoint)[:google_analytics]

end
