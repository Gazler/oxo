defmodule Oxo.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias Oxo.{Repo, User}

  def check_user_password(email, given_pass) do
    user = Repo.get_by(User, email: email)
    cond do
      user && checkpw(given_pass, user.encrypted_password) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        dummy_checkpw()
        {:error, :not_found}
    end
  end
end
