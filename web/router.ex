defmodule Oxo.Router do
  use Oxo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Oxo.Plug.AssignCurrentUser
  end

  pipeline :require_authentication do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Oxo do
    pipe_through [:browser, :browser_session]

    get "/", PageController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :create

    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", Oxo do
    pipe_through [:browser, :browser_session, :require_authentication]

    get "/games/:id", GameController, :show
    resources "/challenges", ChallengeController, only: [:index, :create]
    delete "/logout", SessionController, :delete
  end
end
