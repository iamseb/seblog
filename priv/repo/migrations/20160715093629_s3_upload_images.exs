defmodule Seblog.Repo.Migrations.S3UploadImages do
    use Ecto.Migration
    alias Seblog.Post
    alias Seblog.CachedImage
    alias Seblog.Repo

    def change do
        HTTPoison.start()
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
