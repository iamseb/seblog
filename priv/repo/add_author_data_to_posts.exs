defmodule Seblog.Repo.Migrations.AddAuthorDataToPosts do
  use Ecto.Migration

  def up do
    seb = Seblog.Repo.get_by!(Seblog.Admin, email: "iamseb@gmail.com")

    Seblog.Repo.all(Seblog.Post) |>
    Enum.each(fn(post) ->
      changeset = Seblog.Post.changeset(post, %{"author_id" => seb.id})
      Seblog.Repo.update!(changeset)
    end)

  end
end
