defmodule SlyPanoramaWeb.ExternalLinks do
  @moduledoc """
  Official outbound links, synced from `https://linktr.ee/sly_panorama`.

  When your Linktree changes, update this module (or re-fetch the embedded
  `__NEXT_DATA__` JSON from that page).
  """

  @type link :: {String.t(), String.t(), String.t()}
  @type section :: %{id: String.t(), title: String.t(), links: [link()]}

  @doc """
  Sections for the home page: `{label, url, hero_icon_name}` per link.
  """
  @spec link_sections() :: [section()]
  def link_sections do
    [
      %{
        id: "subscribe",
        title: "Subscribe & watch",
        links: [
          {"OnlyFans", "https://onlyfans.com/sly_panorama/c1", "hero-heart-mini"},
          {"ManyVids", "https://slypanorama4.manyvids.com/", "hero-film-mini"},
          {"Free OnlyFans", "https://onlyfans.com/slypanoramafree/c1", "hero-heart-mini"},
          {"LoyalFans", "https://www.loyalfans.com/slypanorama", "hero-sparkles-mini"},
          {"MintStars", "https://mintstars.com/slypanorama", "hero-star-mini"}
        ]
      },
      %{
        id: "clips",
        title: "Clips & tube profiles",
        links: [
          {"Pornhub", "https://www.pornhub.com/model/sly-panorama", "hero-play-mini"},
          {"xHamster", "https://xhamster.com/users/profiles/slypanorama", "hero-film-mini"},
          {"RedGIFs", "https://www.redgifs.com/users/slypanorama", "hero-photo-mini"}
        ]
      },
      %{
        id: "community",
        title: "Community & wishlist",
        links: [
          {"Throne wishlist", "https://throne.com/slypanorama", "hero-gift-mini"},
          {"Fetlife", "https://fetlife.com/sly_panorama", "hero-link-mini"},
          {"Reddit", "https://www.reddit.com/u/Sly_Panorama/", "hero-chat-bubble-left-right-mini"}
        ]
      },
      %{
        id: "social",
        title: "Social",
        links: [
          {"Instagram", "https://www.instagram.com/SlyPanorama", "hero-camera-mini"},
          {"X", "https://x.com/slypanorama", "hero-at-symbol-mini"},
          {"Threads", "https://www.threads.com/@slypanorama", "hero-hashtag-mini"},
          {"Bluesky", "https://bsky.app/profile/slypanorama.bsky.social", "hero-globe-alt-mini"}
        ]
      }
    ]
  end

  @doc """
  `sameAs` URLs for JSON-LD — distinct profile / storefront URLs.
  """
  def person_same_as do
    link_sections()
    |> Enum.flat_map(& &1.links)
    |> Enum.map(&elem(&1, 1))
    |> Enum.uniq()
  end

  @doc "Hub link for anything not mirrored on this site yet."
  def linktree_url, do: "https://linktr.ee/sly_panorama"
end
