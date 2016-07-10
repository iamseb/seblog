# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Seblog.Repo.insert!(%Seblog.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seblog.Seeds do
    use Seblog.Web, :model
    alias Seblog.Post
    alias Seblog.Tag

    defp parse_json() do

        posts = case File.read("web/data/iamseb-content.json") do
                {:ok, contents} ->
                    contents
                    |> Poison.Parser.parse!
                    |> Map.get("posts")
                _ ->
                    raise "Cannot read json"

        end

        posts
    end


    defp get_full_content(post) do

        uri = Map.get(post, "url") <> "?json=1"
        HTTPoison.start()
        case HTTPoison.get(uri) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                body
                |> Poison.Parser.parse!
                |> Map.get("post")
                |> Map.get("content")
            {:ok, %HTTPoison.Response{status_code: 404}} ->
                raise "Not found: " <> uri
            {:error, %HTTPoison.Error{reason: reason}} ->
                raise "Error at " <> uri <> " - " <> reason
            {:ok, response} ->
                IO.inspect response
                raise "Something went wrong."
            _ -> raise "Failed to load json from: " <> uri
        end
    end


    defp get_tags(data) do
        data
        |> Map.get("tags") 
        |> Enum.map(&(%Tag{slug: Map.get(&1, "slug"), name: Map.get(&1, "title")}))
    end

    defp clean_content(text) do 
        text
        |> String.replace("https://iamseb-dotcom.appspot.com/", "/")
        |> String.replace("src=\"http:", "src=\"https:")
        |> viper_youtube
        |> remove_unity
    end

    defp viper_youtube(text) do
        text
        |> String.replace(~r/<span class=".* vvqyoutube.*\?v=(\w+)".*/, "<iframe src=\"https://www.youtube.com/embed/\\1\" frameborder=\"0\" allowfullscreen></iframe>")
    end

    defp remove_unity(text) do
        text
        |> String.replace(~r/<p><iframe .*WP_UnityObject.*<\/p>/, "")
    end

    defp create_post(data) do
        tags = get_tags(data)
        content = get_full_content(data)
        IO.inspect tags
        Seblog.Repo.insert! %Post{
            title: Map.get(data, "title"),
            slug: Map.get(data, "slug"),
            excerpt: Map.get(data, "content") |> clean_content,
            content: content |> clean_content,
            format: Map.get(data, "format") || "post",
            status: Map.get(data, "status"),
            pub_date: Ecto.DateTime.cast!(Map.get(data, "date")),
            tags: tags
        }
    end

    def import() do
        parse_json()
        |> Enum.map(&(create_post(&1)))
    end


    def create_admin() do
        changeset = Seblog.Admin.changeset(%Seblog.Admin{}, %{"email" => "iamseb@gmail.com", "password_hash" => "$2b$12$gE1kYCVQcGrj76IGeL0TFeuC3kx.t3nRnJmhmqnItXkn.vTxDLCim"})
        Seblog.Repo.insert!(changeset)
    end
end

IO.inspect Seblog.Seeds.import()

