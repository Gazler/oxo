defmodule Oxo.Game do

  alias __MODULE__

  defstruct board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
        players: [],
        status: :waiting,
        x_turn: true,
        winner: nil,
        win_line: []

  def join_user(%Game{players: [p1]} = state, user_id) when user_id == p1, do: state
  def join_user(%Game{players: [p1, p2]} = state, user_id) when user_id in [p1, p2], do: state
  def join_user(%Game{players: players} = state, user_id) when length(players) < 2 do
    update_game_players(state, user_id)
  end
  def join_user(%Game{}, _), do: {:error, :full}

  defp update_game_players(%Game{players: players} = state, user_id) do
    case [user_id | players] do
      [p1]  -> %{state | players: [p1], status: :waiting}
      other -> %{state | players: Enum.shuffle(other), status: :started}
    end
  end

  def update_game_state(%Game{status: :started} = state, index, user_id) do
		with :ok           <- valid_move(state, index),
         {:ok, marker} <- players_turn(state, user_id),
         do: play_turn(state, index, marker),
         else: (other -> other)
  end

  def valid_move(%Game{}, index) when index < 0, do: {:error, :invalid_move}
  def valid_move(%Game{board: board}, index) do
    case Enum.at(board, index, :invalid) do
      nil -> :ok
      _   -> {:error, :invalid_move}
    end
  end

  def players_turn(%Game{players: [user_id, _], x_turn: true}, user_id), do: {:ok, 0}
  def players_turn(%Game{players: [_, user_id], x_turn: false}, user_id), do: {:ok, 1}
  def players_turn(%Game{}, _), do: {:error, :not_player_turn}

  defp play_turn(%Game{} = state, index, marker) do
    state
    |> place_marker(index, marker)
    |> update_game_win_state()
  end

  defp place_marker(%Game{} = state, index, marker) do
    %{state | board: List.replace_at(state.board, index, marker)}
  end

  defp update_game_win_state(%Game{} = state) do
    case won(state) do
      false     -> %{state | x_turn: !state.x_turn}
      :draw     -> %{state | status: :finished, winner: false}
      {x, line} -> %{state | status: :finished, winner: x, win_line: line}
    end
  end

  def won(%Game{board: board}), do: do_won(board)

  defp do_won([w, w, w, _, _, _, _, _, _]) when not is_nil(w), do: {w, [0, 1, 2]}
  defp do_won([_, _, _, w, w, w, _, _, _]) when not is_nil(w), do: {w, [3, 4, 5]}

  defp do_won([_, _, _, _, _, _, w, w, w]) when not is_nil(w), do: {w, [6, 7, 8]}

  defp do_won([w, _, _, w, _, _, w, _, _]) when not is_nil(w), do: {w, [0, 3, 6]}
  defp do_won([_, w, _, _, w, _, _, w, _]) when not is_nil(w), do: {w, [1, 4, 7]}
  defp do_won([_, _, w, _, _, w, _, _, w]) when not is_nil(w), do: {w, [2, 5, 8]}

  defp do_won([w, _, _, _, w, _, _, _, w]) when not is_nil(w), do: {w, [0, 4, 8]}
  defp do_won([_, _, w, _, w, _, w, _, _]) when not is_nil(w), do: {w, [2, 4, 6]}

  defp do_won(board) do
    if nil in board, do: false, else: :draw
  end

end
