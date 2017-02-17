defmodule Seblog.Repo.Migrations.AddPostReadTime do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :read_time, :integer, default: 0
    end

  end
end
