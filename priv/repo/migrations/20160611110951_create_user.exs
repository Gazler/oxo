defmodule Oxo.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string, null: false

      timestamps
    end

    create unique_index(:users, [:email])
  end
end
