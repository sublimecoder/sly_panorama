defmodule SlyPanoramaWeb.BookingLive do
  use SlyPanoramaWeb, :live_view

  alias SlyPanorama.Recaptcha
  alias SlyPanorama.BookingEmail

  @scene_type_options [{"Paid", "Paid"}, {"Unpaid / Collab", "Unpaid/Collab"}]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-sly-bg to-sly-surface px-4 py-10 text-sly-ink sm:px-6">
      <div class="mx-auto max-w-2xl rounded-2xl border border-white/10 bg-sly-surface/60 p-6 shadow-xl backdrop-blur-md sm:p-10">
        <%= if @submitted do %>
          <h2 id="booking-thank-you" class="text-2xl font-bold text-sly-ink">Thank You!</h2>
          <p class="mt-4 text-sly-ink/90">Your request has been submitted successfully.</p>
          <p class="mt-2 text-sly-ink/90">I’ll review your request and get back to you soon.</p>
        <% else %>
          <h2 class="text-xl font-bold text-sly-ink">Book a Scene</h2>
          <p class="mt-4 text-sly-ink/90">
            Thank you for your interest in booking with me. I’m excited to collaborate and create something memorable together.
          </p>
          <p class="mt-3 text-sly-ink/90">
            While I welcome a variety of project ideas, please note that paid shoots are preferred. This helps me dedicate the time, energy, and resources needed to deliver the best possible results.
          </p>
          <p class="mt-3 text-sly-ink/90">
            If you are booking an unpaid shoot, I may change the time or reschedule the shoot if a paid opportunity arises.
          </p>

          <div class="my-8 border-t border-white/10"></div>

          <.form
            for={@form}
            id="booking-form"
            class="space-y-1"
            phx-submit="save"
            phx-hook="RecaptchaV3"
          >
            <.input field={@form[:name]} type="text" label="Name" required />
            <.input field={@form[:email]} type="email" label="Email" required />
            <.input field={@form[:phone]} type="tel" label="Phone" />
            <.input field={@form[:instagram]} type="text" label="Instagram" required />
            <.input field={@form[:x]} type="text" label="X (Twitter)" required />
            <.input field={@form[:website]} type="text" label="Website (OF, Fansly, ManyVids, or other)" required />
            <.input field={@form[:date]} type="date" label="Preferred date" required />
            <.input
              field={@form[:scene_description]}
              type="textarea"
              label="Scene description (be as detailed as possible)"
              rows="6"
              required
            />
            <.input
              field={@form[:type]}
              type="select"
              label="Type of scene"
              prompt="— Type of scene —"
              options={@scene_type_options}
            />

            <fieldset class="mt-4">
              <span class="fieldset-label mb-2 block text-sly-ink">Scene content</span>
              <p :if={@services_error} class="mb-2 text-sm text-sly-danger">{@services_error}</p>
              <div class="space-y-2">
                <%= for service <- @services do %>
                  <label class="flex cursor-pointer items-center gap-2 text-sm text-sly-ink/90">
                    <input
                      type="checkbox"
                      name="services[]"
                      value={service}
                      checked={service in @selected_services}
                      class={[
                        "size-4 shrink-0 rounded border border-sly-muted/60 bg-white text-sly-accent",
                        "focus:ring-2 focus:ring-sly-accent/50"
                      ]}
                    />
                    <span>{service}</span>
                  </label>
                <% end %>
              </div>
            </fieldset>

            <p class="mt-6 text-sm text-sly-ink/90">Thank you for taking the time to fill out this form.</p>

            <input type="hidden" name="recaptcha_token" id="recaptcha_token" value="" />
            <div class="mt-6">
              <.button type="submit" variant="primary" id="booking-submit-btn">
                <.icon name="hero-paper-airplane-mini" class="size-5 shrink-0" /> Submit booking
              </.button>
            </div>
          </.form>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    remote_ip = client_ip(socket)

    {:ok,
     socket
     |> assign(:ip, remote_ip)
     |> assign(:form, Phoenix.Component.to_form(booking_fields_blank(), as: :booking))
     |> assign(:selected_services, [])
     |> assign(:services_error, nil)
     |> assign(:scene_type_options, @scene_type_options)
     |> assign(:submitted, false)
     |> assign(:services, [
       "Photo shoot",
       "MF",
       "MM",
       "MMF",
       "MFM",
       "MMM",
       "FFM",
       "FMF",
       "Oral",
       "Penetrative (one-on-one)",
       "Group sex",
       "Double penetration",
       "JOI / solo performance",
       "Body worship",
       "Fetish / kink"
     ])
     |> assign(:page_title, "Book a scene with Sly Panorama | Sly Panorama")
     |> assign(
       :page_description,
       "Book a paid or collab scene with Sly Panorama — male adult performer and XXX content creator. Submit details, preferred services, and scheduling through this secure form."
     )
     |> assign(
       :page_keywords,
       "Sly Panorama booking, male adult performer, paid shoots, collab scenes, adult content, XXX performer, scene booking"
     )
     |> assign(:canonical_url, SlyPanoramaWeb.SEO.canonical_url("/booking"))
     |> assign(:og_image_url, SlyPanoramaWeb.SEO.og_image_url())}
  end

  @impl true
  def handle_event(
        "save",
        %{"recaptcha_token" => token, "booking" => booking_params} = params,
        socket
      ) do
    services_params =
      params
      |> Map.get("services", [])
      |> List.wrap()

    remote_ip = socket.assigns.ip

    min_score = Recaptcha.min_score()
    verified = Recaptcha.verify(token, remote_ip)

    case verified do
      {:ok, %{"success" => true, "score" => score, "action" => "booking"}} when score >= min_score ->
        case validate_booking(booking_params, services_params) do
          {:ok, _} ->
            BookingEmail.send_booking_email(booking_params, services_params)

            {:noreply,
             socket
             |> assign(:submitted, true)
             |> put_flash(:info, "Booking request submitted successfully!")}

          {:error, errors_kw, services_error} ->
            merged = Map.merge(booking_fields_blank(), booking_params)

            form =
              Phoenix.Component.to_form(merged,
                as: :booking,
                errors: errors_kw,
                action: :validate
              )

            {:noreply,
             socket
             |> assign(:form, form)
             |> assign(:selected_services, services_params)
             |> assign(:services_error, services_error)}
        end

      {:ok, _} ->
        {:noreply, put_flash(socket, :error, "Suspicious activity detected. Please try again.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "reCAPTCHA verification failed.")}
    end
  end

  def handle_event("save", _params, socket) do
    {:noreply, put_flash(socket, :error, "Please complete the form and try again.")}
  end

  defp booking_fields_blank do
    %{
      "name" => "",
      "email" => "",
      "phone" => "",
      "instagram" => "",
      "x" => "",
      "website" => "",
      "date" => "",
      "scene_description" => "",
      "type" => ""
    }
  end

  defp validate_booking(booking_params, service_params) do
    services = List.wrap(service_params)

    errors =
      []
      |> add_field_error(trim(booking_params["name"]) == "", :name, "Name is required")
      |> add_field_error(trim(booking_params["email"]) == "", :email, "Email is required")
      |> add_field_error(
        trim(booking_params["email"]) != "" &&
          !Regex.match?(~r/@/, booking_params["email"] || ""),
        :email,
        "Invalid email"
      )
      |> add_field_error(
        (booking_params["phone"] || "") != "" &&
          !Regex.match?(
            ~r/^\+?1?\s?[-.(]?\d{3}[-.)]?\s?\d{3}[-.]?\d{4}$/,
            booking_params["phone"] || ""
          ),
        :phone,
        "Must have valid phone number"
      )
      |> add_field_error(trim(booking_params["instagram"]) == "", :instagram, "Instagram account is required")
      |> add_field_error(trim(booking_params["x"]) == "", :x, "X account is required")
      |> add_field_error(trim(booking_params["type"]) == "", :type, "Scene type is required")
      |> add_field_error(trim(booking_params["website"]) == "", :website, "Website is required — OF, Fansly, ManyVids, or other")
      |> add_field_error(trim(booking_params["date"]) == "", :date, "Please pick a date for the scene.")
      |> add_field_error(
        String.length(booking_params["scene_description"] || "") < 10,
        :scene_description,
        "Description too short"
      )

    services_error =
      if services == [] do
        "You must select one or more scene content options."
      end

    cond do
      errors != [] || services_error ->
        {:error, Enum.reverse(errors), services_error}

      true ->
        {:ok, nil}
    end
  end

  defp add_field_error(acc, true, field, message), do: [{field, {message, []}} | acc]
  defp add_field_error(acc, false, _field, _message), do: acc

  defp trim(nil), do: ""
  defp trim(s), do: String.trim(s)

  defp client_ip(socket) do
    case get_connect_info(socket, :x_headers) do
      [{"x-forwarded-for", forwarded_ip} | _] ->
        forwarded_ip

      _ ->
        case get_connect_info(socket, :peer_data) do
          %{address: addr} -> addr |> :inet_parse.ntoa() |> to_string()
          _ -> nil
        end
    end
  end
end
