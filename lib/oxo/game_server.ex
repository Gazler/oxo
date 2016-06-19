defmodule Oxo.GameServer do
  use GenServer
  alias Oxo.Game

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
    {:ok, %Game{}}
  end

  def handle_call({:join, user_id}, _from, state) do
    case Game.join_user(state, user_id) do
      %Game{} = state -> {:reply, {:ok, state}, state}
      other           -> {:reply, other, state}
    end
  end

  def handle_call({:play, index, user_id}, _from, state) do
    case Game.update_game_state(state, index, user_id) do
      %Game{} = state     -> {:reply, {:ok, state}, state}
      {:error, _} = error -> {:reply, error, state}
    end
  end
end
