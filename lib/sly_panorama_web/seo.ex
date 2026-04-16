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
  True when two hostnames refer to the same site (case-insensitive, single leading `www.` ignored).
  """
  def same_site_host?(a, b) when is_binary(a) and is_binary(b) do
    apex_host(a) == apex_host(b)
  end

  def same_site_host?(_, _), do: false

  @doc """
  True when `request_host` matches the host of `public_base_url` (including `www` variant).

  Used by `CanonicalizeUrl` so a mis-set `PHX_HOST` (e.g. `.fly.dev` in Fly `[env]`) does not
  redirect-loop when real traffic uses `PUBLIC_BASE_URL`'s domain.
  """
  def public_site_host?(request_host) when is_binary(request_host) do
    case URI.parse(public_base_url()) do
      %URI{host: pub} when is_binary(pub) and pub != "" ->
        same_site_host?(request_host, pub)

      _ ->
        false
    end
  end

  def public_site_host?(_), do: false

  @doc """
  Hostname from `public_base_url/0` (the configured public site), or `:canonical_host` if the URL
  has no host. This is the only hostname `CanonicalizeUrl` accepts without redirecting.
  """
  def canonical_public_host do
    case URI.parse(public_base_url()) do
      %URI{host: h} when is_binary(h) ->
        h = String.trim(h)
        if h != "", do: h, else: canonical_host_fallback()

      _ ->
        canonical_host_fallback()
    end
  end

  defp canonical_host_fallback do
    case Application.get_env(:sly_panorama, :canonical_host, "") do
      h when is_binary(h) ->
        h = String.trim(h)
        if h != "", do: h, else: nil

      _ ->
        nil
    end
  end

  @doc """
  True when `request_host` is exactly the canonical public hostname (case-insensitive).

  `www.example.com` and `example.com` are **not** equivalent here — use `PUBLIC_BASE_URL`'s host
  as the single allowed form; the other redirects via `CanonicalizeUrl`.
  """
  def canonical_hostname?(request_host, preferred_host)
      when is_binary(request_host) and is_binary(preferred_host) do
    normalize_hostname(request_host) == normalize_hostname(preferred_host)
  end

  def canonical_hostname?(_, _), do: false

  def normalize_hostname(h) when is_binary(h), do: h |> String.trim() |> String.downcase()

  defp apex_host(h) when is_binary(h) do
    h = h |> String.trim() |> String.downcase()

    if String.starts_with?(h, "www.") do
      String.slice(h, 4..-1//1)
    else
      h
    end
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

  Uses the same hero asset as the home page; replace the file under `priv/static/images/` if you
  want a wider OG crop without changing the home layout.
  """
  def og_image_url do
    canonical_url("/images/profile.jpeg")
  end

  @doc """
  SameAs URLs for Person JSON-LD (official / verified profiles).

  Mirrors storefronts and socials from `SlyPanoramaWeb.ExternalLinks`.
  """
  def person_same_as do
    SlyPanoramaWeb.ExternalLinks.person_same_as()
  end
end
