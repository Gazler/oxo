defmodule Oxo.Challenge do
  use Oxo.Web, :model

  schema "challenge" do
    field :open, :boolean, default: true
    belongs_to :user, Oxo.User
    belongs_to :challenger, Oxo.User

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:open])
    |> validate_required([:open])
  end
end
