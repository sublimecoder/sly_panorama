defmodule SlyPanoramaWeb.PageController do
  use SlyPanoramaWeb, :controller

  plug :assign_layout_meta_tags

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    conn
    |> assign(:link_sections, SlyPanoramaWeb.ExternalLinks.link_sections())
    |> render(:home, layout: false)
  end

  defp assign_layout_meta_tags(conn, _opts) do
    conn
    |> assign(:page_title, "Sly Panorama — Adult performer & content creator")
    |> assign(
      :page_description,
      "Official site of Sly Panorama — male adult performer and XXX content creator. Links to platforms, booking, and gallery."
    )
    |> assign(
      :page_keywords,
      SlyPanoramaWeb.SEO.append_meta_keywords(
        "Sly Panorama, male performer, adult content, XXX, content creator, booking, gallery, clips, fan platforms"
      )
    )
  end
end
