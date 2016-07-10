defmodule Seblog.PageView do
    use Seblog.Web, :view

    def markdown(id) do
        case File.read("web/data/#{id}.mdown") do
            {:ok, contents} ->
                contents
                |> Earmark.to_html
                |> raw
            _ ->
                "No content found for #{id}"

        end
    end
end
