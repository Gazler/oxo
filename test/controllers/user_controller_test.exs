defmodule Oxo.UserControllerTest do
  use Oxo.ConnCase

  alias Oxo.User
  @valid_attrs %{email: "user@example.com", password: "password", password_confirmation: "password", name: "some content"}
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(User, email: "user@example.com")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end
end
