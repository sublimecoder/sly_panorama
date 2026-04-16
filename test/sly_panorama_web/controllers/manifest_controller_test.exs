defmodule SlyPanoramaWeb.ManifestControllerTest do
  use SlyPanoramaWeb.ConnCase

  test "GET /manifest.json returns a web manifest", %{conn: conn} do
    conn =
      conn
      |> Map.put(:host, "localhost")
      |> get(~p"/manifest.json")

    assert response(conn, 200)
    assert get_resp_header(conn, "content-type") == ["application/manifest+json; charset=utf-8"]

    {:ok, data} = Jason.decode(response(conn, 200))
    assert data["name"] == SlyPanoramaWeb.SEO.site_name()
    assert data["display"] == "standalone"
    assert data["icons"] == []
  end
end
