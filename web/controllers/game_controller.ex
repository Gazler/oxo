defmodule Oxo.GameController do
  use Oxo.Web, :controller

  def show(conn, %{"id" => id}) do
    user_token = Phoenix.Token.sign(conn, "user", conn.assigns.current_user.id)
    render(conn, "show.html", game_id: id, user_token: user_token)
  end
end
