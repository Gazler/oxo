defmodule Oxo.ChallengeTest do
  use Oxo.ModelCase

  alias Oxo.Challenge

  @valid_attrs %{open: true}
  @invalid_attrs %{open: nil}

  test "changeset with valid attributes" do
    changeset = Challenge.changeset(%Challenge{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Challenge.changeset(%Challenge{}, @invalid_attrs)
    refute changeset.valid?
  end
end
