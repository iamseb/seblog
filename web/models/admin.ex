defmodule Seblog.Admin do
    use Seblog.Web, :model

    schema "admins" do
        field :name, :string, default: "Admin"
        field :email, :string
        field :password, :string, virtual: true
        field :password_hash, :string

        timestamps
    end

    @required_fields ~w(name email password)
    @optional_fields ~w()

    @doc """
    Creates a changeset based on the `model` and `params`.

    If no params are provided, an invalid changeset is returned
    with no validation performed.
    """
    def changeset(model, params \\ %{}) do
        model
        |> cast(params, ~w(name email), [])
        |> validate_format(:email, ~r/@/)
    end

    def registration_changeset(model, params) do
      model
      |> changeset(params)
      |> cast(params, ~w(password), [])
      |> validate_length(:password, min: 6)
      |> put_password_hash()
    end

    defp put_password_hash(changeset) do
        case changeset do
            %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
                put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
            _ -> changeset
        end

    end
end
