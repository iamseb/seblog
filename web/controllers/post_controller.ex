defmodule Seblog.PostController do
  use Seblog.Web, :controller

  alias Seblog.Post
  alias Seblog.CachedImage

  plug :scrub_params, "post" when action in [:create, :update]

  defp make_cache_urls(conn, post) do
    cond do
      post == nil ->
        [page_url(conn, :index)]
      true ->
        [
          page_url(conn, :index), 
          page_url(conn, :show, post.pub_date.year, post.pub_date.month, post.slug)
        ]
      end
  end

  def index(conn, _params) do
    posts = Repo.all(from post in Post, order_by: [desc: post.pub_date])
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        GenEvent.notify(Seblog.EventManager, {:notify_content, post})
        Seblog.Cloudflare.purge_cache(make_cache_urls(conn, post))
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    render(conn, "show.html", post: post)
  end 

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def edit(conn, %{"slug" => slug}) do
    post = Repo.get_by!(Post, slug: slug)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end
    

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        GenEvent.notify(Seblog.EventManager, {:notify_content, post})
        Seblog.Cloudflare.purge_cache(make_cache_urls(conn, post))
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    post = Repo.delete!(post)
    Seblog.Cloudflare.purge_cache(make_cache_urls(conn, post))

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end


  def ifttt(conn, _params = %{"key" => key, "post" => post}) do
    secret = Application.get_env(:seblog, Seblog.Endpoint)[:secret_key_base]
    cond do
      secret == key -> 
        ifttt(conn, post)
      true -> 
        text(conn, "Bad Key")
    end
  end


  def ifttt(conn, _post = %{"url" => url, "title" => title, "content" => content, "image" => image}) do
    read_more = "\n<p><a href=\"#{url}\">Read Article</a></p>"
    img = ~s(<img src="#{image}">\n)
    content = img <> content <> read_more
    changeset = Post.changeset(
      %Post{}, 
      %{"title" => title, "content" => content, "status" => "draft"}
    )
    post = Repo.insert!(changeset)
    GenEvent.notify(Seblog.EventManager, {:notify_content, post})
    Seblog.Cloudflare.purge_cache(make_cache_urls(conn, post))
    text(conn, "ok")
  end


  def ifttt(conn, _params) do
    text(conn, "Bad Request")
  end

  def quick_approve_draft(conn, params = %{"id" => id, "key" => key}) do
    post = Repo.get!(Post, id)
    Post.verify_signed_url(post, key)
    changeset = Post.changeset(post, %{"status" => "publish"})
    Repo.update!(changeset)
    IO.puts "Published post: " <> post.slug
    text(conn, "ok")
  end


end

