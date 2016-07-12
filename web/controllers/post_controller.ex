defmodule Seblog.PostController do
  use Seblog.Web, :controller

  alias Seblog.Post

  plug :scrub_params, "post" when action in [:create, :update]

  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, _post} ->
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
    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  def ifttt(conn, params = %{"key" => System.get_env("SECRET_KEY_BASE"), "post" => %{"url" => url, "title" => title, "content" => content, "image" => image}}) do
    read_more = "\n<p><a href=\"#{url}\">Read Article</a></p>"
    img = "<img src=\"#{image}\" />\n"
    content = img <> content <> read_more
    changeset = Post.changeset(%Post{}, %{"title" => title, "content" => "content", "status" => "draft"})
    text(conn, "ok")
  end

  def ifttt(conn, params = %{"key" => _bad_key}) do
    text(conn, "really not ok")
  end

  def ifttt(conn, _params) do
    text(conn, "bad format")
  end


end

