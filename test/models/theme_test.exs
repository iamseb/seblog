defmodule Seblog.ThemeTest do
  use Seblog.ModelCase

  alias Seblog.Theme

  @valid_attrs %{active: true, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Theme.changeset(%Theme{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Theme.changeset(%Theme{}, @invalid_attrs)
    refute changeset.valid?
  end
end
