defmodule Seblog.Repo.Migrations.ReplaceOldWordpressBreaks do
  use Ecto.Migration

  def replace_page_break(post) do
    content = post.content
    new_content = String.replace(content, ~r/\<p\>\<span id="more-..."\>\<\/span\>\<\/p\>/, "<!-- break -->")
    changeset = Seblog.Post.changeset(post, %{"content" => new_content})
    cond do
      map_size(changeset) > 0 ->
        Seblog.Repo.update!(changeset)
      true ->
        IO.puts "\nNo change needed for #{post.slug}"
    end
  end

  def up do
    Seblog.Repo.all(Seblog.Post)
    |> Enum.each(fn(post) -> replace_page_break(post) end)
  end

  def down do
    nil
  end
end
