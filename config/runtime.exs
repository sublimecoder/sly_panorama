import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/sly_panorama start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :sly_panorama,
         SlyPanoramaWeb.Endpoint,
         server: true,
         url: [host: "slypanorama.com", port: 443, scheme: "https"]
end

  # reCAPTCHA v3: in dev/test, fall back to Google's documented test keys when env is unset so
  # `data-recaptcha-site-key` and `api.js?render=` work on localhost. Production must set real keys.
  # https://developers.google.com/recaptcha/docs/faq#id-like-to-run-automated-tests-with-recaptcha.-what-should-i-do
  recaptcha_test_site_key = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
  recaptcha_test_secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

  recaptcha_site_key =
    case System.get_env("RECAPTCHA_SITE_KEY") do
      v when is_binary(v) ->
        case String.trim(v) do
          "" ->
            if config_env() == :prod do
              raise "environment variable RECAPTCHA_SITE_KEY is required in production"
            else
              recaptcha_test_site_key
            end

          trimmed ->
            trimmed
        end

      _ ->
        if config_env() == :prod do
          raise "environment variable RECAPTCHA_SITE_KEY is required in production"
        else
          recaptcha_test_site_key
        end
    end

  recaptcha_secret_key =
    case System.get_env("RECAPTCHA_SECRET_KEY") do
      v when is_binary(v) ->
        case String.trim(v) do
          "" ->
            if config_env() == :prod do
              raise "environment variable RECAPTCHA_SECRET_KEY is required in production"
            else
              recaptcha_test_secret_key
            end

          trimmed ->
            trimmed
        end

      _ ->
        if config_env() == :prod do
          raise "environment variable RECAPTCHA_SECRET_KEY is required in production"
        else
          recaptcha_test_secret_key
        end
    end

  config :sly_panorama, SlyPanorama.Recaptcha,
    site_key: recaptcha_site_key,
    secret_key: recaptcha_secret_key,
    min_score: 0.5

if config_env() == :prod do
  # database_url =
  #   System.get_env("DATABASE_URL") ||
  #     raise """
  #     environment variable DATABASE_URL is missing.
  #     For example: ecto://USER:PASS@HOST/DATABASE
  #     """

  # maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  # config :sly_panorama, SlyPanorama.Repo,
  #   # ssl: true,
  #   url: database_url,
  #   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  #   # For machines with several cores, consider starting multiple pools of `pool_size`
  #   # pool_count: 4,
  #   socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "slypanorama.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  # `PUBLIC_BASE_URL` hostname is the only accepted `Host` when canonical redirect is on
  # (e.g. `www` redirects to non-`www` if this URL uses the apex host).
  public_base_url =
    (System.get_env("PUBLIC_BASE_URL") || "https://slypanorama.com")
    |> String.trim()
    |> String.trim_trailing("/")

  config :sly_panorama, :public_base_url, public_base_url
  config :sly_panorama, :canonical_host, host
  config :sly_panorama, :enable_canonical_redirect, true

  config :sly_panorama, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :sly_panorama, SlyPanoramaWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :sly_panorama, SlyPanoramaWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :sly_panorama, SlyPanoramaWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Mailer — SMTP2GO (Swoosh SMTP adapter)
  #
  # Create SMTP credentials in the SMTP2GO dashboard. Required:
  #   * `SMTP2GO_USERNAME`
  #   * `SMTP2GO_PASSWORD`
  # Optional overrides:
  #   * `SMTP2GO_RELAY` — default mail.smtp2go.com (keep a hostname, not an IP, for TLS)
  #   * `SMTP2GO_PORT` — default 587 (STARTTLS)
  #
  # Booking notifications also require:
  #   * `BOOKING_EMAIL_TO` — destination inbox
  #   * `BOOKING_EMAIL_FROM` — optional; must be @slypanorama.com or @www.slypanorama.com in production
  #   * optional `BOOKING_EMAIL_FROM_NAME`
  #
  smtp_username =
    System.get_env("SMTP2GO_USERNAME") ||
      raise "environment variable SMTP2GO_USERNAME is missing for SMTP2GO mail"

  smtp_password =
    System.get_env("SMTP2GO_PASSWORD") ||
      raise "environment variable SMTP2GO_PASSWORD is missing for SMTP2GO mail"

  smtp_relay = System.get_env("SMTP2GO_RELAY") || "mail.smtp2go.com"

  smtp_port =
    case System.get_env("SMTP2GO_PORT") do
      nil ->
        587

      v ->
        case Integer.parse(String.trim(v)) do
          {port, _} when port > 0 and port < 65536 ->
            port

          _ ->
            raise "environment variable SMTP2GO_PORT must be a valid TCP port number"
        end
    end

  # gen_smtp’s built-in `tls_options` only set old TLS versions; on OTP 26+ the default SSL
  # client behaviour needs a CA bundle and SNI or STARTTLS fails with `:tls_failed`.
  # Use `:public_key.cacerts_get/0` (OTP 25.1+) — not `Certifi`, which is not loaded when this
  # file runs under the release `Config.Reader` and would raise UndefinedFunctionError.
  smtp_tls_options = [
    versions: [:"tlsv1.2", :"tlsv1.3"],
    verify: :verify_peer,
    cacerts: :public_key.cacerts_get(),
    depth: 99,
    server_name_indication: String.to_charlist(smtp_relay),
    customize_hostname_check: [
      match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]
  ]

  config :sly_panorama, SlyPanorama.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: smtp_relay,
    username: smtp_username,
    password: smtp_password,
    port: smtp_port,
    ssl: false,
    tls: :always,
    tls_options: smtp_tls_options,
    auth: :always,
    retries: 2
end
