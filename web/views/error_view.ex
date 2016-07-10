defmodule Seblog.ErrorView do
  use Seblog.Web, :view

  def render("404.html", _assigns) do
    render "not_found.html", %{}
  end

  def render("500.html", _assigns) do
    render "error_message.html", %{}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end

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
