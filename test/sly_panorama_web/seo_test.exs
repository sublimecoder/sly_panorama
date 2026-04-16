defmodule SlyPanoramaWeb.SEOTest do
  use ExUnit.Case

  describe "public_base_url/0" do
    setup do
      previous = Application.get_env(:sly_panorama, :public_base_url)

      on_exit(fn ->
        if previous == nil do
          Application.delete_env(:sly_panorama, :public_base_url)
        else
          Application.put_env(:sly_panorama, :public_base_url, previous)
        end
      end)

      :ok
    end

    test "uses :public_base_url when set" do
      Application.put_env(:sly_panorama, :public_base_url, "https://slypanorama.com/")
      assert SlyPanoramaWeb.SEO.public_base_url() == "https://slypanorama.com"
    end
  end
end
