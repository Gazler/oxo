defmodule Oxo.GameController do
  use Oxo.Web, :controller

  alias Oxo.Challenge

  def show(conn, %{"id" => id}) do
    challenge = Repo.get(Challenge, id)
    current_user_id = conn.assigns.current_user.id

    case challenge do
      %Challenge{user_id: ^current_user_id} ->
        user_token = Phoenix.Token.sign(conn, "user", conn.assigns.current_user.id)
        render(conn, "show.html", game_id: id, user_token: user_token)
      %Challenge{} ->
        challenge
        |> Challenge.changeset(%{open: false})
        |> Repo.update()
        user_token = Phoenix.Token.sign(conn, "user", conn.assigns.current_user.id)
        render(conn, "show.html", game_id: id, user_token: user_token)
      _ ->
        conn
        |> put_flash(:error, "Could not find challenge")
        |> redirect(to: challenge_path(conn, :index))
    end
  end
end
