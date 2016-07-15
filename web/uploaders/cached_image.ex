defmodule Seblog.CachedImage do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original] #, :thumb]

  # def __storage do
  #   case Mix.env do
  #     :prod -> Arc.Storage.S3
  #     _ -> Arc.Storage.Local
  #   end
  # end

  def filename(version,  {file, _scope}) do
    file_name = "#{version}-#{file.file_name}"
    Path.basename(file_name, Path.extname(file_name))
  end

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
  end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    base = Application.get_env(:seblog, Seblog.CachedImage)[:cache_base]
    "#{base}"
  end

    # Provide a default URL if there hasn't been a file uploaded
    # def default_url(version, scope) do
    #   "/images/avatars/default_#{version}.png"
    # end

    # Specify custom headers for s3 objects
    # Available options are [:cache_control, :content_disposition,
    #    :content_encoding, :content_length, :content_type,
    #    :expect, :expires, :storage_class, :website_redirect_location]
    #
  def s3_object_headers(_version, {file, _scope}) do
      [content_type: Plug.MIME.path(file.file_name)]
  end


  def cache_remote_image(url) do
      IO.puts "Getting image: " <> url
      asset_host = Application.get_env(:arc, :asset_host)
      cond do
          url =~ asset_host -> url
          true ->
              url
              |> get_remote_image
              |> store_image
              |> get_cached_image_url
      end
  end

  def get_remote_image(url) do
      url = cond do
        String.starts_with?(url, "//") -> "https:" <> url
        true -> url
      end
      uuid = Ecto.UUID.generate()
      %HTTPoison.Response{headers: headers, body: body} = HTTPoison.get!(url, [], [follow_redirect: true])
      content_type = get_header(headers, "Content-Type")
      ext = Plug.MIME.extensions(content_type || "image/jpeg") |> hd
      path = Plug.Upload.random_file!("image")
      File.write!(path, body)
      upload = %Plug.Upload{content_type: content_type, filename: "#{uuid}.#{ext}", path: path}
      IO.puts "Generated upload: "
      IO.inspect upload
      upload
  end

  def store_image(upload) do
      {:ok, filename} = store(upload)
      filename
  end

  def get_cached_image_url(filename) do
      url(filename)
  end


  defp get_header(headers, key) do
      headers
      |> Enum.filter(fn({k, _}) -> k == key end)
      |> hd
      |> elem(1)
  end


  def replace_images(content) do
      Regex.scan(
        ~r/<img.*?src="(.*?)"/s, 
        content, 
        capture: :all_but_first
        ) 
      |> Enum.reduce([], fn (x, acc) -> acc ++ [x |> hd] end)
      |> Enum.reduce([], fn (x, acc) -> acc ++ [[x, cache_remote_image(x)]] end)
      |> Enum.reduce(content, fn(x, acc) -> String.replace(content, List.first(x), List.last(x)) end)
  end


end
