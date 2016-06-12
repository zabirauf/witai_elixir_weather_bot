defmodule EchoBot.MessagesController do
  use MicrosoftBot.Phoenix.Controller
  alias ExMicrosoftBot.Models.Message

  def message_received(conn, %Message{} = message) do
    Logger.info "message_received: #{inspect(message)}"

    session_id = message.conversationId

    spawn fn ->
      %{from: from, to: to, id: msgId} = message
      context = %{"session" => %{"from" => from, "to" => to, "msgId" => msgId}}
      Logger.info "message_received: context is #{inspect(context)}"

      Wit.run_actions(get_wit_access_token, session_id, EchoBot.WeatherConversationAction, message.text, context, 10)
    end

    resp(conn, 200, "")
  end

  defp get_wit_access_token() do
    Application.get_env(:koinbot, :wit_access_token)
  end

end
