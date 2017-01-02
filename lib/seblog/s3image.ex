defmodule Seblog.S3Image do
  use Arc.Definition
  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def __storage do
    case Mix.env do
      :prod -> Arc.Storage.S3
      _ -> Arc.Storage.Local
    end
  end

  def acl(:thumb, _), do: :public_read

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-thumbnail 100 -format png", :png}
  end

  # def transform(:original, {file, _scope}) do
  #   case Path.extname(file.file_name) do
  #     ".png" -> {:pngcrush, "", :png}
  #     _ -> {:noaction}
  #   end
  # end

  def filename(version,  {file, _scope}) do
    file_name = "#{version}-#{file.file_name}"
    Path.basename(file_name, Path.extname(file_name))
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    base = Application.get_env(:seblog, Seblog.S3Image)[:cache_base]
    "#{base}"
  end

    # Specify custom headers for s3 objects
    # Available options are [:cache_control, :content_disposition,
    #    :content_encoding, :content_length, :content_type,
    #    :expect, :expires, :storage_class, :website_redirect_location]
    #
  def s3_object_headers(_version, {file, _scope}) do
      [content_type: Plug.MIME.path(file.file_name)]
  end


  def default_url(:thumb) do
    "https://placehold.it/100x100"
  end
end
