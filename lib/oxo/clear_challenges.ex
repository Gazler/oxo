defmodule Oxo.ClearChallenges do

  alias Oxo.{User, Challenge, Repo, GameRegistry}
  import Ecto.Query

  def clear_challenges(user, age \\ 300) do
    challenges = get_old_open_challenges(user, age)
    count = length(challenges)
    Repo.transaction(fn ->
      with {:ok, user} <- update_refused_challenges(user, count),
           delete_challenges(challenges),
           stop_games(challenges),
        do: user,
        else: ({error, reason} -> Repo.rollback(reason))
    end)
  end

  defp get_old_open_challenges(user, age) do
    age = age * -1
    Ecto.assoc(user, :challenges)
    |> where(open: true)
    |> where([u], u.inserted_at < datetime_add(^Ecto.DateTime.utc(), ^age, "second"))
    |> Oxo.Repo.all()
  end

  defp delete_challenges(challenges) do
    ids = Enum.map(challenges, &(&1.id))
    query = where(Challenge, [c], c.id in ^ids)
    Repo.delete_all(query)
  end

  defp stop_games(challenges) do
    Enum.map(challenges, &GameRegistry.delete_game(&1.id))
  end

  def update_refused_challenges(user, count) do
    user
    |> User.update_changeset(%{refused_challenges: user.refused_challenges + count})
    |> Repo.update()
  end
end
