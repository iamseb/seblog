defmodule Seblog.Repo.Migrations.CreateAdmin do
  use Ecto.Migration

  def change do
    create table(:admins, primary_key: :false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :password_hash, :string

      timestamps
    end

  end
end
