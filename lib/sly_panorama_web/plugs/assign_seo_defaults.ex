defmodule SlyPanoramaWeb.Plugs.AssignSeoDefaults do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    qs = conn.query_string || ""

    conn
    |> assign(:canonical_url, SlyPanoramaWeb.SEO.canonical_url(conn.request_path, qs))
    |> assign(:og_image_url, SlyPanoramaWeb.SEO.og_image_url())
  end
end
