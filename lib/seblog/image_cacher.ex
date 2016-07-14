defmodule Seblog.ImageCacher do

    alias Seblog.CachedImage

    def cache_remote_image(url) do
        url
        |> get_remote_image
        |> store_image
        |> get_cached_image_url
    end

    def get_remote_image(url) do
        uuid = Ecto.UUID.generate()
        %HTTPoison.Response{body: body} = HTTPoison.get!(url)
        path = "/tmp/#{uuid}"
        File.write!(path, body)
        path
    end

    def store_image(path) do
        {:ok, filename} = CachedImage.store(path)
        filename
    end

    def get_cached_image_url(filename) do
        CachedImage.url(filename)
    end

end