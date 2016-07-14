defmodule Seblog.ImageCacheTest do
    use ExUnit.Case, async: false
    alias Seblog.ImageCacher

    @base Application.get_env(:seblog, Seblog.CachedImage)[:cache_base]

    test "check image cacher works" do
        url = "http://images.sebpotter.com/seb.jpg"
        assert ImageCacher.cache_remote_image(url) =~ "#{@base}/original"
    end

end
