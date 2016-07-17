defmodule Seblog.Post do
  use Seblog.Web, :model

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :status, :string
    field :format, :string, default: "post"
    field :content, :string
    field :excerpt, :string
    field :pub_date, Ecto.DateTime, default: Ecto.DateTime.utc
    many_to_many :tags, Seblog.Tag, join_through: "posts_tags"

    timestamps
  end

  @required_fields ~w(title status content)
  @optional_fields ~w(pub_date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cache_remote_images
    |> make_excerpt
    |> slugify
  end

  def make_excerpt(changeset) do
    excerpt = get_field(changeset, :content)
    excerpt = cond do
      excerpt != nil ->
        excerpt
        |> String.split("<!-- break -->", trim: true) 
        |> Enum.at(0)
      true ->
        ""
    end
    
    put_change(changeset, :excerpt, excerpt)
  end

  def slugify(changeset) do
    slug = get_field(changeset, :title)
    |> Slugger.slugify_downcase
    
    put_change(changeset, :slug, slug)
  end

  def cache_remote_images(changeset) do
    content = get_field(changeset, :content)
    |> Seblog.CachedImage.replace_images

    put_change(changeset, :content, content)
  end
 end
