defmodule Oxo.GameTest do
  use ExUnit.Case

  alias Oxo.Game

  setup do
    game = %Game{status: :started, players: ["p1", "p2"]}
    {:ok, game: game}
  end

  describe "join_user/2" do
    test "adds the players to the list", %{game: game} do
      assert "p1" in game.players
      assert "p2" in game.players
    end

    test "sets the status to started", %{game: game} do
      assert %{status: :started} = game
    end

    test "returns the state if the user is in the game", %{game: game} do
      assert Game.join_user(game, "p1") == game
      assert Game.join_user(game, "p2") == game

      pending_game = %Game{players: ["p1"]}
      assert Game.join_user(pending_game, "p1") == pending_game
    end

    test "returns an error of the game is full", %{game: game} do
      assert Game.join_user(game, "p3") == {:error, :full}
    end
  end

  describe "update_game_state/2" do
    test "it returns a new state when the move is valid", %{game: game} do
      game = Game.update_game_state(game, 0, "p1")
      assert %{board: [0 | _tail], x_turn: false} = game
    end

    test "it returns an error when the move is invalid", %{game: game} do
      assert Game.update_game_state(game, 10, "p1") == {:error, :invalid_move}
    end

    test "it returns when the game is a won", %{game: game} do
      board = [
        0, 0, nil,
        1, 1, nil,
        1, 1, 0
      ]
      game = %{game | board: board}
      win_game_0 = Game.update_game_state(game, 2, "p1")
      assert %{status: :finished, winner: 0, win_line: [0, 1, 2]} = win_game_0

      win_game_1 =
        game
        |> Game.update_game_state(5, "p1")
        |> Game.update_game_state(2, "p2")
      assert %{status: :finished, winner: 1, win_line: [2, 4, 6]} = win_game_1
    end

    test "it returns when the game is a draw", %{game: game} do
      board = [
        0, 0, 1,
        1, 1, nil,
        0, 1, 0
      ]
      game =
        %{game | board: board}
        |> Game.update_game_state(5, "p1")
      assert %{status: :finished, winner: false} = game
    end
  end

  describe "valid_move/2" do
    test "it returns :ok when the move is valid", %{game: game} do
      assert Game.valid_move(game, 0) == :ok
    end

    test "it returns an error with an invalid index", %{game: game} do
      assert Game.valid_move(game, -1) == {:error, :invalid_move}
      assert Game.valid_move(game, 9) == {:error, :invalid_move}
    end

    test "it returns an error with an occupied square", %{game: game} do
      game = Game.update_game_state(game, 0, "p1")
      assert Game.valid_move(game, 0) == {:error, :invalid_move}
    end
  end

  describe "players_turn/2" do
    test "it returns {:ok, marker} when it is the players", %{game: game} do
      assert Game.players_turn(game, "p1") == {:ok, 0}
      game = Game.update_game_state(game, 0, "p1")
      assert Game.players_turn(game, "p2") == {:ok, 1}
    end

    test "it returns an error when it is not the players turn", %{game: game} do
      assert Game.players_turn(game, "p2") == {:error, :not_player_turn}
      game = Game.update_game_state(game, 0, "p1")
      assert Game.players_turn(game, "p1") == {:error, :not_player_turn}
    end
  end

  describe "won/1" do
    test "returns {w, line} when a game is won" do
      wins = [
        {[0, 0, 0, nil, nil, nil, nil, nil, nil], {0, [0, 1, 2]}},
        {[nil, nil, nil, 1, 1, 1, nil, nil, nil], {1, [3, 4, 5]}},
        {[nil, nil, nil, nil, nil, nil, 1, 1, 1], {1, [6, 7, 8]}},

        {[0, nil, nil, 0, nil, nil, 0, nil, nil], {0, [0, 3, 6]}},
        {[nil, 1, nil, nil, 1, nil, nil, 1, nil], {1, [1, 4, 7]}},
        {[nil, nil, 0, nil, nil, 0, nil, nil, 0], {0, [2, 5, 8]}},

        {[0, nil, nil, nil, 0, nil, nil, nil, 0], {0, [0, 4, 8]}},
        {[nil, nil, 1, nil, 1, nil, 1, nil, nil], {1, [2, 4, 6]}},
      ]
      Enum.each(wins, fn {board, result} ->
        assert Game.won(%Game{board: board}) == result
      end)
    end
  end
end
