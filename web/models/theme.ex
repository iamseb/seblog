defmodule Seblog.Theme do
  use Seblog.Web, :model

  schema "themes" do
    field :name, :string
    field :active, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :active])
    |> validate_required([:name, :active])
  end

  def get_current_theme do
    Ecto.Repo.one(from x in Seblog.Theme, where: x.active == true, order_by: [desc: x.updated_at], limit: 1)
  end

end
