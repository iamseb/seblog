defmodule Seblog.Post do
  use Seblog.Web, :model

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :status, :string
    field :format, :string, default: "post"
    field :content, :string
    field :excerpt, :string
    field :read_time, :integer, default: 0
    field :pub_date, Ecto.DateTime, default: Ecto.DateTime.utc
    many_to_many :tags, Seblog.Tag, join_through: "posts_tags"
    belongs_to :author, Seblog.Admin
    timestamps
  end

  @required_fields ~w(title status content author_id)
  @optional_fields ~w(pub_date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> make_excerpt
    |> slugify
    |> foreign_key_constraint(:author_id)
  end

  def make_excerpt(changeset) do
    excerpt = get_field(changeset, :content)
    excerpt = cond do
      excerpt != nil ->
        excerpt
        |> String.split("<!-- break -->", trim: true)
        |> Enum.at(0)
      true ->
        ""
    end

    put_change(changeset, :excerpt, excerpt)
  end

  def slugify(changeset) do
    slug = get_field(changeset, :title)
    |> Slugger.slugify_downcase

    put_change(changeset, :slug, slug)
  end

  def cache_remote_images(changeset) do
    content = get_change(changeset, :content)
    # IO.inspect changeset
    # IO.inspect changeset.data
    cond do
      content == nil ->
        # IO.puts "BAILING OUT OF IMAGE TRANSFORM BECAUSE CONTENT UNCHANGED"
        changeset
      true ->
        content = content
        |> Seblog.CachedImage.replace_images
        put_change(changeset, :content, content)
    end
  end

  def sign_post_url(post) do
    secret = Application.get_env(:seblog, Seblog.Endpoint)[:secret_key_base]
    :crypto.hmac(:sha, secret, Seblog.Router.Helpers.post_url(Seblog.Endpoint, :show, post.id))
    |> Base.encode16
    |> String.downcase
  end

  def verify_signed_url(post, key) do
    unless key == sign_post_url(post) do
      raise ArgumentError, "The key is incorrect"
    end
    {:ok, key}
  end

  def summary_no_image(post) do
    post.excerpt |>
      String.replace(~r/\<img .*\>/, "")
  end

  def content_no_image(post) do
    post.content |>
      String.replace(~r/\<img .*\>/, "")
  end

  def first_image(post) do
    imgs = Regex.run(~r/.*(<img.*>).*/Ums, post.excerpt, capture: :all_but_first)
    cond do
      imgs == nil ->
        nil
      length(imgs) > 0 ->
        hd imgs
      true ->
        nil
    end
  end

  def embedded_link(post) do
    links = Regex.run(~r/.*<a .*href="(.*)".*>Read Article<\/a>.*/Ums, post.excerpt, capture: :all_but_first)
    cond do
      links == nil ->
        nil
      length(links) > 0 ->
        links |> List.last
      true ->
        nil
    end
  end


end
