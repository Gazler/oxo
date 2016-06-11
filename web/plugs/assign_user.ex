defmodule Oxo.Plug.AssignCurrentUser do
  def init(opts \\ []) do
    opts
  end

  @doc false
  def call(conn, opts) do
    current_user = Guardian.Plug.current_resource(conn, :default)
    Plug.Conn.assign(conn, :current_user, current_user)
  end
end
