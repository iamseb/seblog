defmodule Seblog.PageController do
  use Seblog.Web, :controller
  alias Seblog.Post

  plug :put_layout, "public.html"


  def index(conn, _params) do
    by_page(conn, %{"page" => "0"})
  end

  def by_page(conn, %{"page" => page}) do
    limit = 10
    page = String.to_integer(page)
    offset = limit * page
    posts = Repo.all(from post in Post, limit: 10, offset: ^offset, order_by: [desc: post.pub_date])
    count = Repo.aggregate(Post, :count, :id)
    total_pages = Float.floor(count / limit)
    render conn, "index.html", posts: posts, page: page, total_pages: total_pages
  end

  def show(conn, %{"slug" => slug}) do
    post = Repo.get_by!(Post, slug: slug)
    render(conn, "show.html", post: post)
  end
  


end
