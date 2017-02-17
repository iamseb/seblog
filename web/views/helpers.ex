defmodule Seblog.ViewHelper do
  def current_admin(conn), do: Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def site_name(conn), do: Application.get_env(:seblog, Seblog.Endpoint)[:site_name]
  def site_title(conn), do: Application.get_env(:seblog, Seblog.Endpoint)[:site_title]
  def google_analytics(conn), do: Application.get_env(:seblog, Seblog.Endpoint)[:google_analytics]
  def post_no_image(conn, post), do: Seblog.Post.summary_no_image(post)
  def post_image(conn, post), do: Seblog.Post.first_image(post)
  def post_link(conn, post) do
    link = Seblog.Post.embedded_link(post)
    case link do
      nil -> Seblog.Router.Helpers.page_path(conn, :show, post.pub_date.year, post.pub_date.month, post.slug)
      _ -> link
    end
  end
end
