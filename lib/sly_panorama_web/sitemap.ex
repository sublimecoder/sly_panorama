defmodule SlyPanoramaWeb.Sitemap do
  @moduledoc false

  @entries [
    %{path: "/", changefreq: "weekly", priority: "1.0"},
    %{path: "/gallery", changefreq: "weekly", priority: "0.8"},
    %{path: "/booking", changefreq: "monthly", priority: "0.7"}
  ]

  @doc """
  Indexable routes for the public site. Add rows here when you add marketing pages.
  """
  def entries, do: @entries

  @doc "W3C Datetime for `<lastmod>` (UTC date)."
  def lastmod_date do
    Date.utc_today() |> Date.to_iso8601()
  end

  @doc "Full sitemap document (UTF-8 XML)."
  def document do
    base = SlyPanoramaWeb.SEO.public_base_url()

    lastmod = lastmod_date()

    body =
      @entries
      |> Enum.map(fn e ->
        loc = xml_escape("#{base}#{e.path}")

        """
          <url>
            <loc>#{loc}</loc>
            <lastmod>#{lastmod}</lastmod>
            <changefreq>#{e.changefreq}</changefreq>
            <priority>#{e.priority}</priority>
          </url>
        """
      end)
      |> Enum.join("\n")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{body}
    </urlset>
    """
    |> String.trim()
  end

  defp xml_escape(s) when is_binary(s) do
    s
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
