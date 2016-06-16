defmodule Oxo.UserTest do
  use Oxo.ModelCase

  alias Oxo.User

  @valid_attrs %{email: "some content", password: "password", password_confirmation: "password", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
