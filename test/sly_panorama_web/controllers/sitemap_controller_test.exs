defmodule SlyPanoramaWeb.SitemapControllerTest do
  use SlyPanoramaWeb.ConnCase

  test "sitemap uses public_base_url when configured" do
    previous = Application.get_env(:sly_panorama, :public_base_url)

    on_exit(fn ->
      if previous == nil do
        Application.delete_env(:sly_panorama, :public_base_url)
      else
        Application.put_env(:sly_panorama, :public_base_url, previous)
      end
    end)

    Application.put_env(:sly_panorama, :public_base_url, "https://slypanorama.com")
    xml = SlyPanoramaWeb.Sitemap.document()
    assert xml =~ "https://slypanorama.com/gallery"
    refute xml =~ "gigalixirapp.com"
  end

  test "GET /sitemap.xml returns XML with all public URLs", %{conn: conn} do
    conn =
      conn
      |> Map.put(:host, "localhost")
      |> get(~p"/sitemap.xml")

    assert response(conn, 200)
    assert get_resp_header(conn, "content-type") == ["application/xml; charset=utf-8"]

    body = response(conn, 200)
    assert body =~ ~r/<urlset/
    assert body =~ "http://localhost"

    for path <- ["/gallery", "/booking"] do
      assert body =~ path
    end

    assert body =~ ~r/<loc>http:\/\/localhost:\d+\/<\/loc>/

    assert body =~ ~r/<lastmod>\d{4}-\d{2}-\d{2}<\/lastmod>/
  end
end
