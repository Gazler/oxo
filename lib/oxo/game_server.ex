defmodule Oxo.GameServer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def join(pid, user_id) do
    GenServer.call(pid, {:join, user_id})
  end

  def play(pid, index, user_id) do
    GenServer.call(pid, {:play, index, user_id})
  end

  def init(_opts) do
    {:ok,%{
        board: [nil, nil, nil, nil, nil, nil, nil, nil, nil],
        players: [],
        status: :waiting,
        x_turn: true,
        winner: nil,
        win_line: []
    }}
  end

  def handle_call({:join, user_id}, _from, %{players: players} = state) when length(players) < 2 do
    if user_id in state.players do
      {:reply, {:ok, state}, state}
    else
      {players, status} =
        case [user_id | players] do
          [p1]  -> {[p1], :waiting}
          other -> {Enum.shuffle(other), :started}
        end
      new_state = %{state | players: players, status: status}
      {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:join, user_id}, _from, state) do
    if user_id in state.players do
      {:reply, {:ok, state}, state}
    else
      {:reply, {:error, :full}, state}
    end
  end

  def handle_call({:play, index, user_id}, _from, %{status: :started} = state) do
    if valid_move?(state.board, index) do
      case {user_id, state.players, state.x_turn} do
        {uid, [uid, _], true}  -> {:ok, 0}
        {uid, [_, uid], false} -> {:ok, 1}
        _                      -> {:error, :not_player_turn}
      end
      |> case do
        {:ok, marker} ->
          board = List.replace_at(state.board, index, marker)
          state = %{state | board: board}
          state =
            case game_won(board) do
              false ->
                state = %{state | board: board, x_turn: !state.x_turn}
                {:reply, {:ok, state}, state}
              :draw ->
                state = %{state | board: board, status: :finished, winner: false}
                {:reply, {:ok, state}, state}
              {x, line} ->
                state = %{state | board: board, status: :finished, winner: x, win_line: line}
                {:reply, {:ok, state}, state}
          end
        {:error, _} = error ->
          {:reply, error, state}
      end
    else
      {:reply, {:error, :invalid_move}, state}
    end
  end

  defp valid_move?(_board, index) when index < 0, do: false
  defp valid_move?(board, index) do
    case Enum.at(board, index, :invalid) do
      nil -> true
      _   -> false
    end
  end

  defp game_won([a, b, c, d, e, f, g, h, i] = board) do
    cond do
      a == b and b == c and a != nil          -> {a, [0, 1, 2]}
      d == e and e == f and d != nil          -> {d, [3, 4, 5]}
      g == h and h == i and g != nil          -> {g, [6, 7, 8]}

      a == d and d == g and a != nil          -> {a, [0, 3, 6]}
      b == e and e == h and b != nil          -> {b, [1, 4, 7]}
      c == f and f == i and c != nil          -> {c, [2, 5, 8]}

      a == e and e == i and a != nil          -> {a, [0, 4, 8]}
      c == e and e == g and c != nil          -> {c, [2, 4, 6]}

      Enum.any?(board, fn x -> is_nil(x) end) -> false
      true                                    -> :draw
    end
  end
end
