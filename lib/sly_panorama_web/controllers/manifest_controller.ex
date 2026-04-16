defmodule SlyPanoramaWeb.ManifestController do
  use SlyPanoramaWeb, :controller

  def show(conn, _params) do
    body = Jason.encode!(manifest_map())

    conn
    |> put_resp_content_type("application/manifest+json")
    |> send_resp(200, body)
  end

  defp manifest_map do
    base = SlyPanoramaWeb.SEO.public_base_url()

    %{
      "name" => SlyPanoramaWeb.SEO.site_name(),
      "short_name" => SlyPanoramaWeb.SEO.site_name(),
      "description" => SlyPanoramaWeb.SEO.default_description(),
      "start_url" => "#{base}/",
      "scope" => "/",
      "display" => "standalone",
      "background_color" => "#0f0f0f",
      "theme_color" => "#c9a227",
      "lang" => "en",
      "icons" => []
    }
  end
end
