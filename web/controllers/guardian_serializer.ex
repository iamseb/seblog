defmodule Seblog.GuardianSerializer do
  @behaviour Guardian.Serializer
  alias Seblog.Repo
  alias Seblog.Admin
  def for_token(admin = %Admin{}), do: {:ok, "Admin:#{admin.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}
  def from_token("Admin:" <> id), do: {:ok, Repo.get(Admin, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end