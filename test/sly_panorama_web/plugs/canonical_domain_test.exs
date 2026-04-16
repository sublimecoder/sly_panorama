defmodule SlyPanoramaWeb.Plugs.CanonicalizeUrlTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  setup do
    prev_enable = Application.get_env(:sly_panorama, :enable_canonical_redirect)
    prev_base = Application.get_env(:sly_panorama, :public_base_url)

    on_exit(fn ->
      restore(:enable_canonical_redirect, prev_enable)
      restore(:public_base_url, prev_base)
    end)

    Application.put_env(:sly_panorama, :enable_canonical_redirect, true)
    Application.put_env(:sly_panorama, :public_base_url, "https://slypanorama.com")

    :ok
  end

  test "does not redirect when host matches PUBLIC_BASE_URL host exactly" do
    conn =
      :get
      |> conn("/")
      |> Map.put(:host, "slypanorama.com")

    conn = SlyPanoramaWeb.Plugs.CanonicalizeUrl.call(conn, [])

    refute conn.halted
  end

  test "301 redirects www to non-www preserving path and query" do
    conn =
      :get
      |> conn("/gallery?x=1")
      |> Map.put(:host, "www.slypanorama.com")

    conn = SlyPanoramaWeb.Plugs.CanonicalizeUrl.call(conn, [])

    assert conn.halted
    assert conn.status == 301
    assert ["https://slypanorama.com/gallery?x=1"] == get_resp_header(conn, "location")
  end

  defp restore(key, previous) do
    if previous == nil do
      Application.delete_env(:sly_panorama, key)
    else
      Application.put_env(:sly_panorama, key, previous)
    end
  end
end
