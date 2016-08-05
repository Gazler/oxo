defmodule Oxo.Repo.Migrations.AddRefusedChallengesToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :refused_challenges, :integer, null: false, default: 0
    end
  end
end
