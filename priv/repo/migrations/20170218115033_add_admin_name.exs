defmodule Seblog.Repo.Migrations.AddAdminName do
  use Ecto.Migration

  def change do
    alter table(:admins) do
      add :name, :string, default: "Admin"
    end
  end
end
