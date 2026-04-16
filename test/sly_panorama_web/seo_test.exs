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

    test "public_site_host?/1 matches apex and www against public base" do
      Application.put_env(:sly_panorama, :public_base_url, "https://slypanorama.com")

      assert SlyPanoramaWeb.SEO.public_site_host?("slypanorama.com")
      assert SlyPanoramaWeb.SEO.public_site_host?("www.slypanorama.com")
      refute SlyPanoramaWeb.SEO.public_site_host?("sly-panorama.fly.dev")
    end
  end

  describe "same_site_host?/2" do
    test "treats www and apex as equivalent" do
      assert SlyPanoramaWeb.SEO.same_site_host?("www.example.com", "example.com")
      assert SlyPanoramaWeb.SEO.same_site_host?("Example.COM", "www.example.com")
      refute SlyPanoramaWeb.SEO.same_site_host?("other.com", "example.com")
    end
  end
end
