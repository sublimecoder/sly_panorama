defmodule SlyPanoramaWeb.Plugs.CanonicalizeUrl do
  import Plug.Conn
  use SlyPanoramaWeb, :controller

  def init(options), do: options

  def call(conn, _opts) do
    if Application.get_env(:sly_panorama, :enable_canonical_redirect, false) do
      canonicalize(conn)
    else
      conn
    end
  end

  defp canonicalize(conn) do
    case SlyPanoramaWeb.SEO.canonical_public_host() do
      nil ->
        conn

      preferred ->
        host = conn.host

        cond do
          SlyPanoramaWeb.SEO.normalize_hostname(host) == "localhost" ->
            conn

          SlyPanoramaWeb.SEO.canonical_hostname?(host, preferred) ->
            conn

          true ->
            location =
              SlyPanoramaWeb.SEO.canonical_url(conn.request_path, conn.query_string)

            conn
            |> put_status(:moved_permanently)
            |> redirect(external: location)
            |> halt()
        end
    end
  end
end
