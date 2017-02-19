defmodule Seblog.Repo.Migrations.AddAuthorToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :author_id, references(:admins, on_delete: :nothing, type: :uuid)
    end

    create index(:posts, [:author_id])
  end
end
