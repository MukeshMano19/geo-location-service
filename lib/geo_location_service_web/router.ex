defmodule GeoLocationServiceWeb.Router do
  use GeoLocationServiceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GeoLocationServiceWeb do
    pipe_through :browser

    get "/", DatasetController, :page_index
  end

  scope "/api", GeoLocationServiceWeb do
    pipe_through :api

    get "/geo_locations/:ip_address", DatasetController, :get_dataset_by_ip
    resources "/datasets", DatasetController, except: [:new, :edit]
  end
end
