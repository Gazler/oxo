defmodule Oxo.GameRegistry do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def find_game(id) do
    GenServer.call(__MODULE__, {:find_game, id})
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:find_game, id}, _from, state) do
    pid = case state[id] do
      pid when is_pid(pid) -> pid
      nil                  -> start_game(id)
    end
    {:reply, {:ok, pid}, Map.put(state, id, pid)}
  end

  defp start_game(id) do
    {:ok, pid} = GenServer.start_link(Oxo.GameServer, [])
    pid
  end
end
