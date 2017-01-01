defmodule Seblog.Repo.Migrations.CreateImage do
  use Ecto.Migration

  def change do
    create table(:images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string
      add :name, :string
      add :base_url, :string
      add :description, :string

      timestamps()
    end

  end
end
