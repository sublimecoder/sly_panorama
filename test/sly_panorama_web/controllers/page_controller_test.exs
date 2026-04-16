defmodule SlyPanoramaWeb.PageControllerTest do
  use SlyPanoramaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = conn |> Map.put(:host, "localhost") |> get(~p"/")
    html = html_response(conn, 200)
    assert html =~ "Sly Panorama"
    assert html =~ ~r/<link[^>]+rel="canonical"[^>]+href="http:\/\/localhost:\d+\/"/
  end
end
