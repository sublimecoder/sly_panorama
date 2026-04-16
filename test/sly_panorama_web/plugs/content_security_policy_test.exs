defmodule SlyPanoramaWeb.Plugs.ContentSecurityPolicyTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  test "sets content-security-policy allowing Google reCAPTCHA hosts" do
    conn =
      :get
      |> conn("/")
      |> SlyPanoramaWeb.Plugs.ContentSecurityPolicy.call([])

    [csp] = get_resp_header(conn, "content-security-policy")

    assert String.contains?(csp, "script-src")
    assert String.contains?(csp, "https://www.gstatic.com")
    assert String.contains?(csp, "https://www.google.com")
    assert String.contains?(csp, "frame-src")
    assert String.contains?(csp, "https://recaptcha.google.com")
    assert String.contains?(csp, "font-src 'self' data: https:")
  end
end
