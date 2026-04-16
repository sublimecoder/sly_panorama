defmodule SlyPanoramaWeb.SitemapController do
  use SlyPanoramaWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, SlyPanoramaWeb.Sitemap.document())
  end
end
