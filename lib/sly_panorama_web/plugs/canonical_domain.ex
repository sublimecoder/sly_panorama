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
          |> redirect(external: origin <> conn.request_path, status: 301)
          |> halt()
      end
    else
      conn
    end
  end

  defp canonical_host?(host, canonical) do
    host == canonical or host == "www." <> canonical or host == "localhost"
  end
end
