defmodule EchoBot.WeatherClient do
  require Logger

  def get_weather(location) do
    get_params = %{"q" => location, "appid" => get_openweathermap_appid}
    url = "http://api.openweathermap.org/data/2.5/weather?"
    |> create_url(get_params)

    Logger.info "Fetching weather using #{inspect(url)}"
    url
    |> HTTPotion.get
    |> deserialize
  end

  defp create_url(endpoint, %{} = get_params) do
    Map.keys(get_params)
    |> Enum.reduce(endpoint, fn(key, url) ->
      append_to_url(url, key, Map.get(get_params, key))
    end)
  end

  defp append_to_url(url, _key, ""), do: url
  defp append_to_url(url, key, param), do: "#{url}&#{key}=#{param}"

  defp deserialize(%HTTPotion.Response{status_code: 200} = resp) do
    {:ok, Poison.decode!(resp.body)}
  end
  defp deserialize(%HTTPotion.Response{status_code: code} = resp) do
    {:error, "Invalid status code #{code}", resp}
  end

  defp get_openweathermap_appid() do
    Application.get_env(:openweathermap, :app_id)
  end

end
