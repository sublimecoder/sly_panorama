defmodule SlyPanoramaWeb.GalleryController do
  use SlyPanoramaWeb, :controller

  plug :assign_layout_meta_tags

  def index(conn, _params) do
    images = get_images()

    gallery_images_json =
      images
      |> Enum.map(fn {file, title} ->
        %{"src" => "/images/gallery/#{file}", "title" => title}
      end)
      |> Jason.encode!()

    render(conn, :index, images: images, gallery_images_json: gallery_images_json)
  end

  defp get_images do
    []
  end

  defp assign_layout_meta_tags(conn, _opts) do
    conn
    |> assign(:page_title, "Gallery | Sly Panorama")
    |> assign(
      :page_description,
      "Photo gallery for Sly Panorama — adult performer and content creator. New images will appear here as they are published."
    )
    |> assign(
      :page_keywords,
      "Sly Panorama, adult performer, content creator, gallery, XXX, photos"
    )
  end
end
