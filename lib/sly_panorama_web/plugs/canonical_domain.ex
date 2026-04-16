defmodule SlyPanoramaWeb.Plugs.CanonicalizeUrl do
  import Plug.Conn
  use SlyPanoramaWeb, :controller

  def init(options), do: options

  def call(conn, _opts) do
    if Application.get_env(:sly_panorama, :enable_canonical_redirect, false) do
      canonical = Application.get_env(:sly_panorama, :canonical_host, "")

      cond do
        not is_binary(canonical) or canonical == "" ->
          conn

        canonical_host?(conn.host, canonical) ->
          conn

        true ->
          origin = SlyPanoramaWeb.SEO.public_base_url() |> String.trim_trailing("/")

          conn
          |> put_status(:moved_permanently)
          |> redirect(external: origin <> conn.request_path)
          |> halt()
      end
    else
      conn
    end
  end

  defp canonical_host?(host, canonical) do
    host == "localhost" or
      SlyPanoramaWeb.SEO.same_site_host?(host, canonical) or
      SlyPanoramaWeb.SEO.public_site_host?(host)
  end
end
