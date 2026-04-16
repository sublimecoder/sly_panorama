defmodule SlyPanorama.BookingEmail do
  @moduledoc """
  Builds and delivers booking notification mail via `SlyPanorama.Mailer`.

  In production the mailer uses **Amazon SES** (`Swoosh.Adapters.AmazonSES`). Set:

  * `BOOKING_EMAIL_TO` — inbox that receives submissions (required in prod if unset below fails closed only when deliver runs)
  * `BOOKING_EMAIL_FROM` — full **SES-verified** From address, e.g. `bookings@yourdomain.com` (required for SES)
  * Optional `BOOKING_EMAIL_FROM_NAME` — display name (defaults to \"Sly Panorama bookings\")
  """

  alias SlyPanorama.Mailer
  import Swoosh.Email

  @default_from_name "Sly Panorama bookings"

  @doc """
  Sends the booking request email. Returns `{:ok, metadata}` or `{:error, reason}` from `Mailer.deliver/1`.
  """
  @spec send_booking_email(map(), [String.t()]) :: {:ok, term()} | {:error, term()}
  def send_booking_email(booking, services) when is_map(booking) do
    to = booking_to()
    {from_name, from_address} = from_tuple()
    reply =
      case trim(booking["name"]) do
        "" -> trim(booking["email"])
        name -> {name, trim(booking["email"])}
      end

    text = build_text_body(booking, services)
    html = build_html_body(booking, services)

    email =
      new()
      |> to(to)
      |> from({from_name, from_address})
      |> reply_to(reply)
      |> subject(subject_line(booking))
      |> text_body(text)
      |> html_body(html)
      |> maybe_put_aws_session_token()

    Mailer.deliver(email)
  end

  defp subject_line(booking) do
    name = trim(booking["name"])
    date = trim(booking["date"])
    "[Sly Panorama] Booking — #{name} — #{date}"
  end

  defp build_text_body(booking, services) do
    """
    New booking request (slypanorama.com)

    Name: #{trim(booking["name"])}
    Email: #{trim(booking["email"])}
    Phone: #{trim(booking["phone"])}
    Instagram: #{trim(booking["instagram"])}
    X: #{trim(booking["x"])}
    Website: #{trim(booking["website"])}
    Preferred date: #{trim(booking["date"])}
    Scene type: #{trim(booking["type"])}

    Scene description:
    #{trim(booking["scene_description"])}

    Scene content requested:
    #{Enum.join(services, ", ")}
    """
    |> String.trim()
  end

  defp build_html_body(booking, services) do
    rows = [
      {"Name", booking["name"]},
      {"Email", booking["email"]},
      {"Phone", booking["phone"]},
      {"Instagram", booking["instagram"]},
      {"X", booking["x"]},
      {"Website", booking["website"]},
      {"Preferred date", booking["date"]},
      {"Scene type", booking["type"]}
    ]

    rows_html =
      for {label, value} <- rows do
        ~s"""
        <tr>
          <td style="padding:8px 12px;border:1px solid #e5e5e5;background:#fafafa;font-weight:600;width:160px;">#{h(label)}</td>
          <td style="padding:8px 12px;border:1px solid #e5e5e5;">#{h(value)}</td>
        </tr>
        """
      end
      |> IO.iodata_to_binary()

    """
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"></head>
    <body style="margin:0;padding:24px;background:#f4f4f5;font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;color:#111827;">
      <table role="presentation" cellpadding="0" cellspacing="0" style="max-width:640px;margin:0 auto;background:#ffffff;border-radius:12px;overflow:hidden;border:1px solid #e5e7eb;">
        <tr>
          <td style="padding:24px 28px;background:#0f0f0f;color:#f5e6b3;">
            <h1 style="margin:0;font-size:20px;font-weight:700;">New booking request</h1>
            <p style="margin:8px 0 0;font-size:14px;opacity:0.9;">Reply to this message goes to the submitter’s email.</p>
          </td>
        </tr>
        <tr>
          <td style="padding:24px 28px;">
            <h2 style="margin:0 0 12px;font-size:16px;color:#374151;">Contact &amp; logistics</h2>
            <table role="presentation" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;font-size:14px;">
              #{rows_html}
            </table>
            <h2 style="margin:24px 0 12px;font-size:16px;color:#374151;">Scene description</h2>
            <div style="white-space:pre-wrap;font-size:14px;line-height:1.55;padding:14px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;">#{h(booking["scene_description"])}</div>
            <h2 style="margin:24px 0 12px;font-size:16px;color:#374151;">Scene content requested</h2>
            <p style="margin:0;font-size:14px;line-height:1.55;">#{h(Enum.join(services, ", "))}</p>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """
  end

  defp h(nil), do: ""

  defp h(value) do
    value |> to_string() |> Plug.HTML.html_escape()
  end

  defp trim(nil), do: ""
  defp trim(s), do: String.trim(to_string(s))

  defp from_tuple do
    name = System.get_env("BOOKING_EMAIL_FROM_NAME") || @default_from_name

    address =
      case booking_from_address() do
        {:ok, addr} -> addr
        :error -> raise "BOOKING_EMAIL_FROM must be set to a verified SES sender address (e.g. bookings@yourdomain.com)"
      end

    {name, address}
  end

  defp booking_from_address do
    case System.get_env("BOOKING_EMAIL_FROM") do
      v when is_binary(v) ->
        v = String.trim(v)
        if v != "", do: {:ok, v}, else: maybe_dev_from()

      _ ->
        maybe_dev_from()
    end
  end

  defp maybe_dev_from do
    if local_mailer?(), do: {:ok, "bookings@localhost"}, else: :error
  end

  defp booking_to do
    case System.get_env("BOOKING_EMAIL_TO") do
      v when is_binary(v) ->
        v = String.trim(v)
        if v != "", do: v, else: maybe_dev_to()

      _ ->
        maybe_dev_to()
    end
  end

  defp maybe_dev_to do
    if local_mailer?(), do: "bookings@localhost", else: raise_missing!("BOOKING_EMAIL_TO")
  end

  defp local_mailer? do
    Application.get_env(:sly_panorama, SlyPanorama.Mailer, [])[:adapter] in [
      Swoosh.Adapters.Local,
      Swoosh.Adapters.Test
    ]
  end

  defp raise_missing!(var) do
    raise "#{var} must be set for the configured mailer (Amazon SES in production)"
  end

  defp maybe_put_aws_session_token(email) do
    case System.get_env("AWS_SESSION_TOKEN") do
      token when is_binary(token) ->
        token = String.trim(token)
        if token != "", do: put_provider_option(email, :security_token, token), else: email

      _ ->
        email
    end
  end
end
