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
    {response, state} =
      case Game.join_user(user_id, state) do
        {:ok, state} = response -> {response, state}
        response                -> {response, state}
      end
    {:reply, response, state}
  end

  def handle_call({:play, index, user_id}, _from, state) do
    {response, state} =
      case Game.play_turn_for(index, user_id, state) do
        {:ok, state} = response -> {response, state}
        response                -> {response, state}
      end
    {:reply, response, state}
  end
end
