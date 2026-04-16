# lib/sly_panorama/recaptcha.ex
defmodule SlyPanorama.Recaptcha do
  @verify_url "https://www.google.com/recaptcha/api/siteverify"

  def site_key, do: config!(:site_key)
  def secret_key, do: config!(:secret_key)
  def min_score, do: config!(:min_score)

  def verify(token, remote_ip \\ nil) do
    form =
      %{
        secret: secret_key(),
        response: token
      }
      |> maybe_put(:remoteip, remote_ip)

    case Req.post(@verify_url, form: form) do
      {:ok, %{status: 200, body: body}} -> parse_response(body)
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_response(%{"success" => true} = body) do
    {:ok, body}
  end

  defp parse_response(%{"success" => false, "error-codes" => errors}),
    do: {:error, {:recaptcha, errors}}

  defp parse_response(_), do: {:error, :unexpected_response}

  defp config!(key) do
    Application.fetch_env!(:sly_panorama, __MODULE__)
    |> Keyword.fetch!(key)
  end

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)
end
