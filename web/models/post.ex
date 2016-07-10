defmodule Seblog.Post do
  use Seblog.Web, :model

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :status, :string
    field :format, :string
    field :content, :string
    field :excerpt, :string
    field :pub_date, Ecto.DateTime
    many_to_many :tags, Seblog.Tag, join_through: "posts_tags"

    timestamps
  end

  @required_fields ~w(title slug status content excerpt)
  @optional_fields ~w(pub_date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
