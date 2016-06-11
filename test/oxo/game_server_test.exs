defmodule Oxo.GameServerTest do
  use ExUnit.Case

  alias Oxo.GameServer

  setup do
    {:ok, pid} = GameServer.start_link()
    {:ok, pid: pid}
  end

  test "join will join at most 2 players", %{pid: pid} do
    {:ok, %{players: ["123"], status: :waiting}} = GameServer.join(pid, "123")
    # the players are shuffled so we just check for their presence
    {:ok, %{players: players, status: :started}} = GameServer.join(pid, "456")
    assert "123" in players
    assert "456" in players
    {:error, :full} = GameServer.join(pid, "789")
  end

  test "join will return the state for an existing player", %{pid: pid} do
    {:ok, state} = GameServer.join(pid, "123")
    {:ok, ^state} = GameServer.join(pid, "123")
  end

  test "play will place the current users piece at index", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: _} = started_game(context)
    {:ok, %{board: board}} = GameServer.play(pid, 0, player_1)
    assert board == [0, nil, nil, nil, nil, nil, nil, nil, nil]
  end

  test "play will only permit the current player to play", context do
    {:ok, pid: pid, state: _, player_1: _, player_2: player_2} = started_game(context)
    assert {:error, :not_player_turn} = GameServer.play(pid, 0, player_2)
  end

  test "play will alternate the users turn", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: player_2} = started_game(context)
    assert {:ok, _} = GameServer.play(pid, 0, player_1)
    assert {:ok, _} = GameServer.play(pid, 5, player_2)
  end

  test "play will not overwrite an existing piece", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: player_2} = started_game(context)
    assert {:ok, _} = GameServer.play(pid, 0, player_1)
    assert {:error, :invalid_move} = GameServer.play(pid, 0, player_2)
    assert {:ok, _} = GameServer.play(pid, 5, player_2)
  end

  test "play will not allow a move out of bounds", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: _} = started_game(context)
    assert {:error, :invalid_move} = GameServer.play(pid, 10, player_1)
    assert {:error, :invalid_move} = GameServer.play(pid, -1, player_1)
  end

  test "play will continue until the X wins", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: player_2} = started_game(context)
    assert {:ok, _} = GameServer.play(pid, 0, player_1)
    assert {:ok, _} = GameServer.play(pid, 3, player_2)
    assert {:ok, _} = GameServer.play(pid, 1, player_1)
    assert {:ok, _} = GameServer.play(pid, 4, player_2)
    assert {:ok, state} = GameServer.play(pid, 2, player_1)
    assert state.winner == 0
    assert state.status == :finished
    assert state.win_line == [0, 1, 2]
    assert state.board == [0, 0, 0,
                           1, 1, nil,
                           nil, nil, nil]
  end

  test "play will continue until the O wins", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: player_2} = started_game(context)
    assert {:ok, _} = GameServer.play(pid, 0, player_1)
    assert {:ok, _} = GameServer.play(pid, 3, player_2)
    assert {:ok, _} = GameServer.play(pid, 1, player_1)
    assert {:ok, _} = GameServer.play(pid, 4, player_2)
    assert {:ok, _} = GameServer.play(pid, 6, player_1)
    assert {:ok, state} = GameServer.play(pid, 5, player_2)
    assert state.winner == 1
    assert state.status == :finished
    assert state.win_line == [3, 4, 5]
    assert state.board == [0, 0, nil,
                           1, 1, 1,
                           0, nil, nil]
  end

  test "play will continue until there is a draw", context do
    {:ok, pid: pid, state: _, player_1: player_1, player_2: player_2} = started_game(context)
    assert {:ok, _} = GameServer.play(pid, 0, player_1)
    assert {:ok, _} = GameServer.play(pid, 3, player_2)
    assert {:ok, _} = GameServer.play(pid, 1, player_1)
    assert {:ok, _} = GameServer.play(pid, 4, player_2)
    assert {:ok, _} = GameServer.play(pid, 6, player_1)
    assert {:ok, _} = GameServer.play(pid, 7, player_2)
    assert {:ok, _} = GameServer.play(pid, 8, player_1)
    assert {:ok, _} = GameServer.play(pid, 2, player_2)
    assert {:ok, state} = GameServer.play(pid, 5, player_1)
    assert state.winner == false
    assert state.status == :finished
    assert state.win_line == []
    assert state.board == [0, 0, 1,
                           1, 1, 0,
                           0, 1, 0]
  end

  defp started_game(context) do
    pid = context.pid
    {:ok, _} = GameServer.join(pid, "123")
    {:ok, state} = GameServer.join(pid, "456")
    [player_1, player_2] = state.players
    {:ok, pid: pid, state: state, player_1: player_1, player_2: player_2}
  end
end
