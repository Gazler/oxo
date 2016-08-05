defmodule Oxo.ClearChallenges do

  alias Oxo.{User, Challenge, Repo, GameRegistry}
  import Ecto.Query

  def clear_challenges(user, age \\ 300) do
    challenges = get_old_open_challenges(user, age)
    count = length(challenges)
    params = %{refused_challenges: user.refused_challenges + count}

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.update_changeset(user, params))
    |> Ecto.Multi.delete_all(:challenges, delete_challenges_query(challenges))
    |> Ecto.Multi.run(:games, fn _ -> stop_games(challenges) end)
    |> Repo.transaction()
  end

  defp get_old_open_challenges(user, age) do
    age = age * -1
    Ecto.assoc(user, :challenges)
    |> where(open: true)
    |> where([u], u.inserted_at < datetime_add(^Ecto.DateTime.utc(), ^age, "second"))
    |> Oxo.Repo.all()
  end

  defp delete_challenges_query(challenges) do
    ids = Enum.map(challenges, &(&1.id))
    query = where(Challenge, [c], c.id in ^ids)
  end

  defp stop_games(challenges) do
    Enum.map(challenges, &GameRegistry.delete_game(&1.id))
    {:ok, :stopped_games}
  end
end
