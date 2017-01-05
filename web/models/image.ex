defmodule Seblog.Image do
  use Seblog.Web, :model
  use Arc.Ecto.Schema

  schema "images" do
    field :slug, :string
    field :name, :string
    field :base_url, Seblog.S3Image.Type
    field :description, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug, :name, :base_url, :description])
    |> cast_attachments(params, [:base_url])
    |> validate_required([:slug, :name, :base_url, :description])
  end

  def thumb_url(image, signed \\ :false) do
    Seblog.S3Image.url({image.base_url, image}, :thumb, signed: signed)
    |> Seblog.S3Image.url_base
  end

  def full_url(image, signed \\ :false) do
    Seblog.S3Image.url({image.base_url, image}, :original, signed: signed)
    |> Seblog.S3Image.url_base
  end

  def content_url(image, signed \\ :false) do
    Seblog.S3Image.url({image.base_url, image}, :contentimage, signed: signed)
    |> Seblog.S3Image.url_base
  end

  defp local_path do
    Application.get_env(:arc, :local_dir) || ""
  end
end
