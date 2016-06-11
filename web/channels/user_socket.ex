defmodule Oxo.UserSocket do
  use Phoenix.Socket
  alias Oxo.Repo
  alias Oxo.User

  channel "games:*", Oxo.GameChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user", token, max_age: 1209600) do
      {:ok, user_id} ->
        socket = assign(socket, :user, Repo.get!(User, user_id))
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Oxo.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
