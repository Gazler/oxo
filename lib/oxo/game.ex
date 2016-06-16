defmodule Oxo.Game do

  defstruct board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
    players: [],
    status: :waiting,
    x_turn: true,
    winner: nil,
    win_line: []

  @doc """
  # TODO
  """
  def game_won([w, w, w, _, _, _, _, _, _]) when not is_nil(w), do: {w, [0, 1, 2]}
  def game_won([_, _, _, w, w, w, _, _, _]) when not is_nil(w), do: {w, [3, 4, 5]}
  def game_won([_, _, _, _, _, _, w, w, w]) when not is_nil(w), do: {w, [6, 7, 8]}

  def game_won([w, _, _, w, _, _, w, _, _]) when not is_nil(w), do: {w, [0, 3, 6]}
  def game_won([_, w, _, _, w, _, _, w, _]) when not is_nil(w), do: {w, [1, 4, 7]}
  def game_won([_, _, w, _, _, w, _, _, w]) when not is_nil(w), do: {w, [2, 5, 8]}

  def game_won([w, _, _, _, w, _, _, _, w]) when not is_nil(w), do: {w, [0, 4, 8]}
  def game_won([_, _, w, _, w, _, w, _, _]) when not is_nil(w), do: {w, [2, 4, 6]}

  def game_won(board) do
    if Enum.any?(board, &is_nil/1), do: false, else: :draw
  end

  def valid_move(_board, index) when index < 0, do: {:error, :invalid_move}
  def valid_move(board, index) do
    case Enum.at(board, index, :invalid) do
      nil -> :ok
      _   -> {:error, :invalid_move}
    end
  end

  def user_in_room(user_id, %{players: players}), do: user_id in players

  def check_all_players_present(user_id, players)do
    case [user_id | players] do
      [p1]  -> {[p1], :waiting}
      other -> {Enum.shuffle(other), :started}
    end
  end


  def players_turn(uid, %{players: [uid, _], x_turn: true}), do: {:ok, 0}
  def players_turn(uid, %{players: [_, uid], x_turn: false}), do: {:ok, 1}
  def players_turn(_, _), do: {:error, :not_player_turn}

  def update_game_state(state, index, marker) do
    state
    |> play_move(index, marker)
    |> update_game_win_state()
  end

  def play_move(state, index, marker) do
    board = List.replace_at(state.board, index, marker)
    %{state | board: board}
  end

  def update_game_win_state(state) do
    case game_won(state.board) do
      false     -> %{state | x_turn: !state.x_turn}
      :draw     -> %{state | status: :finished, winner: false}
      {x, line} -> %{state | status: :finished, winner: x, win_line: line}
    end
  end

  def join_user(user_id, %{players: players} = state) when length(players) < 2 do
    state = if user_in_room(user_id, state) do
      {:ok, state}
    else
      {players, status} = check_all_players_present(user_id, players)
      {:ok, %{state | players: players, status: status}}
    end
  end

  def join_user(user_id, state) do
    if user_in_room(user_id, state), do: {:ok, state}, else: {:error, :full}
  end

  def play_turn_for(index, user_id, %{status: :started} = state) do
    with :ok          <- valid_move(state.board, index),
        {:ok, marker} <- players_turn(user_id, state),
        new_state     =  update_game_state(state, index, marker),
        do: {:ok, new_state},
        else: (other -> other)
  end
end
