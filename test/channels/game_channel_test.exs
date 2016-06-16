defmodule Oxo.GameChannelTest do
  use Oxo.ChannelCase

  alias Oxo.{GameChannel, User, GameServer, GameRegistry}

  setup do
    {:ok, pid} = GameRegistry.find_game("abc")
    {:ok, _, socket} =
      socket("user_id", %{game_pid: pid, user: %User{id: "123"}})
      |> subscribe_and_join(GameChannel, "games:abc")

    {:ok, %{players: players}} = GameServer.join(pid, "456")
    case players do
      ["456", "123"] -> GameServer.play(pid, 5, "456")
      _              -> nil
    end
    {:ok, socket: socket}
  end

  test "game:move plays for a started game", %{socket: socket} do
    push socket, "game:move", %{"index" => "3"}
    assert_broadcast("game:update", _any)
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
