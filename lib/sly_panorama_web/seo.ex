defmodule SlyPanoramaWeb.SEO do
  @moduledoc false

  @site_name "Sly Panorama"

  @default_page_title "Sly Panorama — Official site"

  @default_description "Official site of Sly Panorama — adult performer, content creator, gallery, and booking."

  def site_name, do: @site_name

  def default_page_title, do: @default_page_title

  def default_description, do: @default_description

  @doc """
  Public origin (`https://your-domain.com`) for SEO, sitemaps, Open Graph, and manifests.

  Set `config :sly_panorama, :public_base_url` when the app is reachable on a host that is not
  your canonical domain (e.g. Gigalixir `*.gigalixirapp.com` while `PHX_HOST` matches that host).
  In production this is set in `config/runtime.exs` from `PUBLIC_BASE_URL` or defaults from
  `PHX_HOST`.

  Falls back to `Endpoint.url/0` when unset (typical in dev/test).
  """
  def public_base_url do
    case Application.get_env(:sly_panorama, :public_base_url) do
      url when is_binary(url) ->
        case url |> String.trim() |> String.trim_trailing("/") do
          "" -> endpoint_origin()
          origin -> origin
        end

      _ ->
        endpoint_origin()
    end
  end

  defp endpoint_origin do
    SlyPanoramaWeb.Endpoint.url() |> String.trim_trailing("/")
  end

  @doc """
  Absolute URL for the canonical public site + path + optional query string.
  """
  def canonical_url(request_path, query_string \\ "")

  def canonical_url(request_path, query_string) when is_binary(request_path) do
    base = public_base_url()

    path =
      case request_path do
        "" -> "/"
        <<"/", _::binary>> -> request_path
        p -> "/" <> p
      end

    q =
      case query_string do
        nil -> ""
        "" -> ""
        s -> "?" <> s
      end

    base <> path <> q
  end

  @doc """
  Default share image (absolute URL).

  Add `priv/static/images/og-share.jpg` (or change this path) when you have a card image.
  """
  def og_image_url do
    canonical_url("/images/og-share.jpg")
  end

  @doc """
  SameAs URLs for Person JSON-LD (official / verified profiles).

  Populate with your real profile URLs when ready.
  """
  def person_same_as do
    []
  end
end
