defmodule Oxo.GameChannel do
  use Oxo.Web, :channel
  alias Oxo.{GameRegistry, GameServer}

  def join("games:" <> id, payload, socket) do
    {:ok, pid} = GameRegistry.find_game(id)
    socket = assign(socket, :game_pid, pid)
    case GameServer.join(pid, socket.assigns.user.id) do
      {:ok, %{status: :started} = state} ->
        send(self(), {:game_started, state})
        {:ok, socket}
      {:ok, %{status: :finisned} = state} ->
        {:ok, state, socket}
      {:ok, state}    -> {:ok, state, socket}
      {:error, :full} -> {:error, %{error: "game is full"}}
    end
  end

  def handle_in("game:move", %{"index" => index}, socket) do
    index = String.to_integer(index)
    case GameServer.play(socket.assigns.game_pid, index, socket.assigns.user.id) do
      {:ok, %{status: :started} = state} ->
        broadcast(socket, "game:update", state)
        {:noreply, socket}
        {:ok, %{status: :finished} = state} ->
          broadcast(socket, "game:over", state)
        {:noreply, socket}
      {:error, reason} ->
        {:reply, {:ok, %{error: reason}}, socket}
    end
  end

  def handle_info({:game_started, state}, socket) do
    broadcast(socket, "game:start", state)
    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
