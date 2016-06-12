defmodule EchoBot.WeatherConversationAction do
  require Logger
  use Wit.Actions
  alias Wit.Models.Response.Converse, as: WitConverse
  alias ExMicrosoftBot.Client

  @doc """
  Sending message received from Wit back to messenger
  """
  def say(_session_id, %{} = context, %WitConverse{msg: msg_to_send} = message) do
    Logger.info "Going to say #{inspect(message)} using context #{inspect(context)}"
    %{"session" => %{"from" => to, "to" => from, "msgId" => msgId}} = context

    message_to_send = %{from: from, to: to, replyToMessageId: msgId, text: msg_to_send}
    Client.send_message(get_bot_auth_data(), message_to_send)
  end

  @doc """
  Merge the information to context
  """
  def merge(_session_id, %{} = context, %WitConverse{} = message) do
    Logger.info "Merging context: #{inspect(context)} \n message: #{inspect(message)}"

    %WitConverse{entities: %{"location" => [%{"value" =>  location}|_]}} = message
    Map.put(context, "loc", location)
  end

  @doc """
  Called on error
  """
  def error(_session, %{} = _context, error) do
    Logger.error "Error recieved #{inspect(error)}"
  end

  ####################
  ## Custom Actions ##
  ####################

  @doc """
  Fetches the weather
  """
  defaction fetch_weather(_session_id, %{} = context) do
    Logger.info "Fetching weather from context #{inspect(context)}"
    location = Map.get(context, "loc")

    case EchoBot.WeatherClient.get_weather(location) do
      # Get the weather for the lcoation in the context
      {:ok, %{"main" => %{"temp" => temp}}} ->
        # Returning back the updated context
        Map.put(context, "temperature", kelvin_to_fahrenheit(temp) |> round)
      _ ->
        context
    end
  end

  @doc """
  Called when the story has ended
  """
  defaction story_ended(_session_id, %{} = context) do
    Logger.info "Story ended"
    context
  end

  #######################
  ## Private Functions ##
  #######################

  defp kelvin_to_fahrenheit(temp) do
    temp * (9.0/5.0) - 459.67
  end

  def get_bot_auth_data() do
    %ExMicrosoftBot.Models.AuthData{
      app_id: Application.get_env(:microsoftbot, :app_id),
      app_secret: Application.get_env(:microsoftbot, :app_secret)
    }
  end
end
