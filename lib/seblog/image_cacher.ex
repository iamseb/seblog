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
        ext = url |> Path.extname |> String.split("?") |> hd |> String.split(".") |> hd
        path = Plug.Upload.random_file!("image")
        File.write!(path, body)
        mime = Plug.MIME.type(ext)
        %Plug.Upload{content_type: mime, filename: "#{uuid}.#{ext}", path: path}
    end

    def store_image(upload) do
        {:ok, filename} = CachedImage.store(upload)
        filename
    end

    def get_cached_image_url(filename) do
        CachedImage.url(filename)
    end

end