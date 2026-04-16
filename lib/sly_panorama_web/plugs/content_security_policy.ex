defmodule SlyPanoramaWeb.Plugs.ContentSecurityPolicy do
  @moduledoc """
  Sets `content-security-policy` so the app works with LiveView, inline JSON-LD, and
  Google reCAPTCHA v3 (`www.google.com` / `www.gstatic.com`).

  Replaces Phoenix's minimal default so `script-src` / `frame-src` / `connect-src` explicitly
  allow reCAPTCHA (some platforms also send a stricter Report-Only policy at the edge).

  `font-src` allows any `https:` origin (same idea as `img-src`) so webfonts from CDNs work
  without listing every host.
  """

  import Plug.Conn

  @google_recaptcha "https://www.google.com https://www.gstatic.com"
  @google_recaptcha_frames "#{@google_recaptcha} https://recaptcha.google.com"

  @policy Enum.join(
            [
              "base-uri 'self'",
              "frame-ancestors 'self'",
              "script-src 'self' 'unsafe-inline' #{@google_recaptcha}",
              "style-src 'self' 'unsafe-inline' #{@google_recaptcha}",
              "img-src 'self' data: blob: https:",
              "font-src 'self' data: https:",
              "connect-src 'self' #{@google_recaptcha}",
              "frame-src 'self' #{@google_recaptcha_frames}",
              "manifest-src 'self'",
              "form-action 'self'"
            ],
            "; "
          )

  def init(opts), do: opts

  def call(conn, _opts) do
    put_resp_header(conn, "content-security-policy", @policy)
  end
end
