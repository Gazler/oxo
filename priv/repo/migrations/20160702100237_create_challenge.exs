defmodule Oxo.Repo.Migrations.CreateChallenge do
  use Ecto.Migration

  def change do
    create table(:challenge, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :open, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :challenger_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps
    end
    create index(:challenge, [:user_id])

  end
end
