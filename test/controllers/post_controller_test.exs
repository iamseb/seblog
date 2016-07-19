defmodule Seblog.PostControllerTest do
  use Seblog.ConnCase, async: false

  alias Seblog.Post
  @valid_attrs %{content: "some content", excerpt: "some content", pub_date: "2010-04-17 14:00:00", slug: "some content", status: "publish", title: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing posts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, post_path(conn, :new)
    assert html_response(conn, 200) =~ "New post"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :index)
    assert Repo.get_by(Post, slug: Slugger.slugify_downcase("some content"))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert html_response(conn, 200) =~ "New post"
  end

  test "shows chosen resource", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = get conn, post_path(conn, :show, post)
    assert html_response(conn, 200) =~ "Show post"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = get conn, post_path(conn, :edit, post)
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, post), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :show, post)
    assert Repo.get_by(Post, slug: Slugger.slugify_downcase("some content"))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "deletes chosen resource", %{conn: conn} do
    post = Repo.insert! %Post{}
    _ = put conn, post_path(conn, :update, post), post: @valid_attrs
    conn = delete conn, post_path(conn, :delete, post)
    assert redirected_to(conn) == post_path(conn, :index)
    refute Repo.get(Post, post.id)
  end

  @ifttt_attrs %{content: "This is some content", title: "This is a title", url: "https://sebpotter.com", image: "https://upload.wikimedia.org/wikipedia/commons/c/c4/PM5544_with_non-PAL_signals.png"}

  test "creates post from ifttt web call", %{} do
    conn = build_conn
    key = Application.get_env(:seblog, Seblog.Endpoint)[:secret_key_base]
    uri = post_path(conn, :ifttt) <> "?key=" <> URI.encode(key)
    conn = post conn, uri, post: @ifttt_attrs
    assert text_response(conn, 200) =~ "ok"
    assert Repo.get_by(Post, slug: Slugger.slugify_downcase(@ifttt_attrs.title))
  end

  test "draft creates email notification",  %{conn: conn} do
    draft_attrs = Map.put(@valid_attrs, :status, "draft")
    IO.inspect draft_attrs
    conn = post conn, post_path(conn, :create), post: draft_attrs
    assert redirected_to(conn) == post_path(conn, :index)
    post = Repo.get_by(Post, slug: Slugger.slugify_downcase(draft_attrs.title))
    # wait for 1 second for async notify to complete
    :timer.sleep(1000)
    assert File.read!("/tmp/mailgun.json") =~ post.id
  end

  @image_attrs %{content: ~s(This is a test <img src="http://images.sebpotter.com/disaster.jpg" data-fullsize="https://images.sebpotter.com/original-full.jpg" /> with some content), pub_date: "2010-04-17 14:00:00", status: "publish", title: "some content"}
  test "images not changed when content unchanged",  %{conn: conn} do
    in_conn = post conn, post_path(conn, :create), post: @image_attrs
    assert redirected_to(in_conn) == post_path(in_conn, :index)
    post = Repo.get_by(Post, slug: Slugger.slugify_downcase(@image_attrs.title))
    assert post.content == ~s(This is a test <img src="https://images.sebpotter.com/web/static/assets/img_cache/thumb-full.png" data-fullsize="https://images.sebpotter.com/web/static/assets/img_cache/original-full.jpg"  /> with some content)
    up_conn = put conn, post_path(conn, :update, post), post: %{content: post.content}
    post = Repo.get_by(Post, slug: post.slug)
    assert redirected_to(up_conn) == post_path(up_conn, :show, post)
    assert post.content == ~s(This is a test <img src="https://images.sebpotter.com/web/static/assets/img_cache/thumb-full.png" data-fullsize="https://images.sebpotter.com/web/static/assets/img_cache/original-full.jpg"  /> with some content)
  end

  test "signed url for draft approval" do
    conn = build_conn
    key = Application.get_env(:seblog, Seblog.Endpoint)[:secret_key_base]
    uri = post_path(conn, :ifttt) <> "?key=" <> URI.encode(key)
    conn = post conn, uri, post: @ifttt_attrs
    assert text_response(conn, 200) =~ "ok"
    post = Repo.get_by(Post, slug: Slugger.slugify_downcase(@ifttt_attrs.title))
    
    key = Post.sign_post_url(post)
    assert {:ok, key} == Post.verify_signed_url(post, key)
  end


  test "draft approval publishes post" do
    conn = build_conn
    key = Application.get_env(:seblog, Seblog.Endpoint)[:secret_key_base]
    uri = post_path(conn, :ifttt) <> "?key=" <> URI.encode(key)
    conn = post conn, uri, post: @ifttt_attrs
    assert text_response(conn, 200) =~ "ok"
    post = Repo.get_by(Post, slug: Slugger.slugify_downcase(@ifttt_attrs.title))
    
    key = Post.sign_post_url(post)
    conn = build_conn
    url = post_path(conn, :quick_approve_draft, post.id, Post.sign_post_url(post))
    conn = get conn, url
    assert text_response(conn, 200) =~ "ok"
    post = Repo.get(Post, post.id)
    assert post.status == "publish"


  end


  test "invalid key for draft approval does not publish post" do
    conn = build_conn
    key = Application.get_env(:seblog, Seblog.Endpoint)[:secret_key_base]
    uri = post_path(conn, :ifttt) <> "?key=" <> URI.encode(key)
    conn = post conn, uri, post: @ifttt_attrs
    assert text_response(conn, 200) =~ "ok"
    post = Repo.get_by(Post, slug: Slugger.slugify_downcase(@ifttt_attrs.title))
    
    key = "12345678901234567890"
    conn = build_conn
    url = post_path(conn, :quick_approve_draft, post.id, key)
    assert_raise ArgumentError, "The key is incorrect", fn() -> 
      conn = get conn, url
    end
    post = Repo.get(Post, post.id)
    assert post.status == "draft"


  end


end
