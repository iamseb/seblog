defmodule Seblog.Tag do
  use Seblog.Web, :model

  schema "tags" do
    field :name, :string
    field :slug, :string
    many_to_many :posts, Seblog.Post, join_through: "posts_tags"

    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w()

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
