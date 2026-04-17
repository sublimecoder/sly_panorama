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

  describe "append_meta_keywords/1" do
    test "appends slypanorama and sly_panorama" do
      assert SlyPanoramaWeb.SEO.append_meta_keywords("foo, bar") ==
               "foo, bar, slypanorama, sly_panorama"
    end
  end

  describe "same_site_host?/2" do
    test "treats www and apex as equivalent" do
      assert SlyPanoramaWeb.SEO.same_site_host?("www.example.com", "example.com")
      assert SlyPanoramaWeb.SEO.same_site_host?("Example.COM", "www.example.com")
      refute SlyPanoramaWeb.SEO.same_site_host?("other.com", "example.com")
    end
  end

  describe "canonical_public_host/0 and canonical_hostname?/2" do
    setup do
      previous_base = Application.get_env(:sly_panorama, :public_base_url)
      previous_canonical = Application.get_env(:sly_panorama, :canonical_host)

      on_exit(fn ->
        restore_env(:public_base_url, previous_base)
        restore_env(:canonical_host, previous_canonical)
      end)

      :ok
    end

    test "canonical_public_host prefers host from public_base_url" do
      Application.put_env(:sly_panorama, :public_base_url, "https://slypanorama.com")
      Application.put_env(:sly_panorama, :canonical_host, "ignored.example")

      assert SlyPanoramaWeb.SEO.canonical_public_host() == "slypanorama.com"
    end

    test "canonical_hostname? is strict about www vs apex" do
      assert SlyPanoramaWeb.SEO.canonical_hostname?("slypanorama.com", "slypanorama.com")
      assert SlyPanoramaWeb.SEO.canonical_hostname?("SlyPanorama.COM", "slypanorama.com")
      refute SlyPanoramaWeb.SEO.canonical_hostname?("www.slypanorama.com", "slypanorama.com")
      refute SlyPanoramaWeb.SEO.canonical_hostname?("slypanorama.com", "www.slypanorama.com")
    end
  end

  defp restore_env(key, previous) do
    if previous == nil do
      Application.delete_env(:sly_panorama, key)
    else
      Application.put_env(:sly_panorama, key, previous)
    end
  end
end
