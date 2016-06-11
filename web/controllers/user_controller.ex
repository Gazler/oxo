defmodule Oxo.UserController do
  use Oxo.Web, :controller

  alias Oxo.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        redirect(put_flash(Guardian.Plug.sign_in(conn, user), :info, "User creted successfully"), to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
