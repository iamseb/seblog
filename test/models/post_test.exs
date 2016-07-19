defmodule Seblog.PostTest do
  use Seblog.ModelCase

  alias Seblog.Post

  @valid_attrs %{content: "some content", excerpt: "some content", pub_date: "2010-04-17 14:00:00", slug: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end

end
