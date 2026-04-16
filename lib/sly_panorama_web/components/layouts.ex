defmodule SlyPanoramaWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use SlyPanoramaWeb, :html

  embed_templates "layouts/*"

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  JSON-LD `@graph`: WebSite, ProfilePage (home), and Person with sameAs.
  """
  def website_json_ld(assigns) do
    home = SlyPanoramaWeb.SEO.canonical_url("/")
    person_id = "#{home}#person"
    page_id = "#{home}#webpage"

    graph = [
      %{
        "@type" => "WebSite",
        "name" => SlyPanoramaWeb.SEO.site_name(),
        "url" => home
      },
      %{
        "@type" => "ProfilePage",
        "@id" => page_id,
        "url" => home,
        "name" => "#{SlyPanoramaWeb.SEO.site_name()} — home",
        "isPartOf" => %{"@type" => "WebSite", "url" => home},
        "mainEntity" => %{"@id" => person_id}
      },
      %{
        "@type" => "Person",
        "@id" => person_id,
        "name" => SlyPanoramaWeb.SEO.site_name(),
        "url" => home,
        "image" => SlyPanoramaWeb.SEO.og_image_url(),
        "sameAs" => SlyPanoramaWeb.SEO.person_same_as()
      }
    ]

    payload = Jason.encode!(%{"@context" => "https://schema.org", "@graph" => graph})
    assigns = assign(assigns, :json_ld, payload)

    ~H"""
    <script type="application/ld+json" phx-no-curly-interpolation>
      <%= raw(@json_ld) %>
    </script>
    """
  end
end
