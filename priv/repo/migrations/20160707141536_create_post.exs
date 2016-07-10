defmodule Seblog.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: :false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :slug, :string
      add :format, :string
      add :status, :string
      add :content, :text
      add :excerpt, :text
      add :pub_date, :datetime

      timestamps
    end

  end
end
