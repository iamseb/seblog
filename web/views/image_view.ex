defmodule Seblog.ImageView do
  use Seblog.Web, :view

  def render("pallette.json", %{images: images}) do
    %{
      images: Enum.map(images, &image_json/1)
    }
  end

  def image_json(image) do
    %{
      name: image.name,
      slug: image.slug,
      thumbnail: Seblog.Image.thumb_url(image),
      url: Seblog.Image.full_url(image)
    }
  end

end
