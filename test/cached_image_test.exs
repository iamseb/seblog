defmodule Seblog.CachedImageTest do
  use Seblog.ConnCase

  test "deals with existing content", %{} do
    content = ~s(This is a test <img src="http://images.sebpotter.com/disaster.jpg" data-fullsize="https://images.sebpotter.com/original-full.jpg" /> with some content)
    new_content = Seblog.CachedImage.replace_images(content)
    expected = ~s(This is a test <img src=\"https://images.sebpotter.com/web/static/assets/img_cache/thumb-full.png\" data-fullsize=\"https://images.sebpotter.com/web/static/assets/img_cache/original-full.jpg\"  /> with some content)

    assert expected == new_content

  end


end