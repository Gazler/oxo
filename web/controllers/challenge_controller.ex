defmodule Oxo.ChallengeController do
  use Oxo.Web, :controller

  alias Oxo.Challenge

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    challenges =
      Challenge
      |> Ecto.Query.where(open: true)
      |> Ecto.Query.where([c], c.user_id != ^current_user.id)
      |> Repo.all()
      |> Repo.preload(:user)
    render(conn, "index.html", challenges: challenges)
  end

  def create(conn, _params) do
    current_user = conn.assigns.current_user
    challenge =
      current_user
      |> Ecto.build_assoc(:challenges)
      |> Challenge.changeset(%{})
      |> Repo.insert!()

    redirect(conn, to: game_path(conn, :show, challenge))
  end
end
