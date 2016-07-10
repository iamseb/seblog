defmodule Seblog.Repo.Migrations.AddTagsPostsMany do
  use Ecto.Migration

  def change do
    create table(:posts_tags, primary_key: false) do
        add :post_id, references(:posts, type: :uuid)
        add :tag_id, references(:tags, type: :uuid)
    end
  end
end
