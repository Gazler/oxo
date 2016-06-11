defmodule Oxo.SessionController do
  use Oxo.Web, :controller

  alias Oxo.Auth

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Auth.check_user_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Logged in.")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_status(422)
        |> put_flash(:error, "Invalid username or password")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
