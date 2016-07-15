defmodule Seblog.Repo.Migrations.S3UploadImages do
    use Ecto.Migration
    alias Seblog.Post
    alias Seblog.CachedImage
    alias Seblog.Repo


    def ensure_all_deps_started() do
        Application.load(:seblog)
        Enum.map(Application.spec(:seblog, :applications), &Application.load(&1))
        Enum.map(Application.spec(:seblog, :applications), &Application.ensure_all_started(&1))
      end

    def change do
        ensure_all_deps_started
        Repo.all(Post)
        |> Enum.each(fn(post) -> update_post(post) end)
    end


    def update_post(post) do
        changeset = try do
            Post.changeset(post, %{:content => Seblog.CachedImage.replace_images(post.content)})
        rescue
            e in ArgumentError -> 
                IO.inspect e
                Post.changeset(post, %{:status => "draft"})
            e in HTTPoison.Error -> 
                IO.inspect e
                Post.changeset(post, %{:status => "draft"})                
        end
        Repo.update!(changeset)
    end

end
