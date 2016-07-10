defmodule Seblog.Plug.CustomPageTitle do

  def init(default), do: default

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:page_title, Keyword.get(opts, :title))
  end

end