defmodule Seblog.Router do
  use Seblog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.EnsureAuthenticated, handler: Seblog.Token
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/", Seblog do
    pipe_through [:api]
    post "/admin/posts/ifttt", PostController, :ifttt
  end

  scope "/", Seblog do
    pipe_through [:browser, :browser_auth]
    get "/:year/:date/:slug/write", PostController, :edit
    post "/admin/posts/:id/publish", PostController, :publish
    resources "/admin/posts", PostController
    resources "/admin/tags", TagController
    resources "/admin/images", ImageController
  end


  scope "/", Seblog do
    pipe_through :browser # Use the default browser stack
    resources "/admin/sessions", SessionController, only: [:new, :create, :delete]
    resources "/admin/admins", AdminController
    get "/page/:page", PageController, :by_page
    get "/", PageController, :index
    get "/approve-draft/:id/:key", PostController, :quick_approve_draft
    get "/:year/:date/:slug", PageController, :show
  end



  # Other scopes may use custom stacks.
  # scope "/api", Seblog do
  #   pipe_through :api
  # end
end
