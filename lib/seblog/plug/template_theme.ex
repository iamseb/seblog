defmodule Seblog.Plug.TemplateTheme do
    import Plug.Conn

    def init(assigns), do: assigns

    def call(conn, assigns) do
        Enum.reduce assigns, conn, fn {k, v}, conn ->
            Plug.Conn.assign(conn, k, v)
        end
    end
end
