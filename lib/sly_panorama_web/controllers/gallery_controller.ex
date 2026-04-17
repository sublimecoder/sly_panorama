defmodule SlyPanoramaWeb.GalleryController do
  use SlyPanoramaWeb, :controller

  plug :assign_layout_meta_tags

  def index(conn, _params) do
    images = get_images()

    gallery_images_json =
      images
      |> Enum.map(fn {file, alt} ->
        %{"src" => "/images/gallery/#{file}", "title" => alt}
      end)
      |> Jason.encode!()

    render(conn, :index, images: images, gallery_images_json: gallery_images_json)
  end

  # Second tuple element is `alt` text only (shown in markup, not as a visible caption).
  defp get_images do
    [
      {"sly_portrait_lounge_glasses.jpeg",
       "Sly Panorama portrait wearing glasses in a dim lounge with mirror reflections behind him."},
      {"sly_shirtless_smiling_abstract_art_wall.jpeg",
       "Sly Panorama shirtless, smiling, with blue and gold abstract art on the wall behind him."},
      {"sly_shirtless_selfie_blue_gold_wall_art.jpeg",
       "Sly Panorama shirtless selfie at home with blue wall and swirling blue, white, and gold artwork."},
      {"sly_shirtless_grey_wall_damask_art.jpeg",
       "Sly Panorama shirtless selfie in front of a grey wall with framed damask-style art."},
      {"sly_shirtless_bed_grey_sheets.jpeg",
       "Sly Panorama shirtless on a bed with grey sheets, hand on chest, looking at the camera."},
      {"sly_shirtless_bed_white_pillows_headboard.jpg",
       "Sly Panorama shirtless on white pillows with a tufted dark headboard behind him."},
      {"sly_shirtless_bed_white_pillows_relaxed.jpg",
       "Sly Panorama shirtless portrait reclining on white bed pillows."},
      {"sly_shirtless_bed_pillow_closeup.jpg",
       "Sly Panorama close-up shirtless selfie on white pillows in soft bedroom light."},
      {"sly_shirtless_closeup_charcoal_bedding.jpeg",
       "Sly Panorama shirtless close-up lying on charcoal grey bedding."},
      {"sly_shirtless_smiling_blue_gold_triptych.jpg",
       "Sly Panorama shirtless and smiling with a large blue and gold triptych art piece behind him."},
      {"sly_car_selfie_daylight.jpeg",
       "Sly Panorama selfie in the driver seat of a car wearing glasses and a seatbelt, daylight in a parking lot."},
      {"sly_gym_squirtle_tank.jpeg",
       "Sly Panorama at the gym in a Squirtle graphic tank top, glasses, and beard."},
      {"sly_airport_charizard_cap_night.jpeg",
       "Sly Panorama at an airport terminal wearing a Charizard cap, backpack, and pink tee."},
      {"sly_nightclub_neon_selfie.jpeg",
       "Sly Panorama selfie in a neon-lit nightclub with poles and colorful club lighting behind him."},
      {"sly_tiki_bar_blue_booth_smiling.jpg",
       "Sly Panorama smiling in a tiki-style bar seated in a bright blue booth with tropical wall decor."},
      {"sly_convention_expo_chaturbate_lanyard.jpeg",
       "Sly Panorama at an adult industry convention wearing a Chaturbate lanyard and grey hoodie near expo banners."},
      {"sly_with_friend_pub_selfie.jpeg",
       "Sly Panorama selfie with a friend in a dim pub with framed memorabilia on the walls behind them."}
    ]
  end

  defp assign_layout_meta_tags(conn, _opts) do
    conn
    |> assign(:page_title, "Gallery | Sly Panorama")
    |> assign(
      :page_description,
      "A curated collection of Sly Panorama’s moments on and off camera—high-quality visuals, behind-the-scenes, and candid shots. No explicit content on this page; full access is for subscribers."
    )
    |> assign(
      :page_keywords,
      SlyPanoramaWeb.SEO.append_meta_keywords(
        "Sly Panorama, adult performer, content creator, gallery, XXX, photos"
      )
    )
  end
end
