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
      {:ok, post} ->
        purge_cache(post, conn)
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
        purge_cache(post, conn)
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
    purge_cache(post, conn)

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
    img = "<img src=\"#{image}\" />\n"
    content = img <> content <> read_more
    changeset = Post.changeset(
      %Post{}, 
      %{"title" => title, "content" => content, "status" => "draft"}
    )
    Repo.insert!(changeset) |> purge_cache(conn)
    text(conn, "ok")
  end


  def ifttt(conn, _params) do
    text(conn, "Bad Request")
  end

  @api_user Application.get_env(:seblog, Seblog.Endpoint)[:cloudflare_api_user]
  @api_key Application.get_env(:seblog, Seblog.Endpoint)[:cloudflare_api_key]

  def purge_cache(post, conn) do
    case Mix.prod do
      :test -> 
        
        cf_headers = %{"X-Auth-Email" => @api_user, "X-Auth-Key" => @api_key, "Content-Type" => "application/json"}
        HTTPoison.start()
        case HTTPoison.get("https://api.cloudflare.com/client/v4/zones?name=sebpotter.com&status=active", cf_headers) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            body
            |> Poison.Parser.parse!
            |> Map.get("result")
            |> Enum.each(fn(x) -> call_cache_url(conn, Map.get(x, "id"), post) end)
            post
          _ ->
            post
        end
      _ ->
        post
    end
  end

  defp call_cache_url(conn, zone_id, post) do
    cf_headers = %{"X-Auth-Email" => @api_user, "X-Auth-Key" => @api_key, "Content-Type" => "application/json"}
    HTTPoison.start()
    data = %{files: [page_url(conn, :index), page_url(conn, :show, post.pub_date.year, post.pub_date.month, post.slug)]} |> Poison.encode!
    IO.inspect HTTPoison.request(
      :delete,
      "https://api.cloudflare.com/client/v4/zones/#{zone_id}/purge_cache", 
      data, 
      cf_headers
    )
  end

end

