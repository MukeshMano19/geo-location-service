defmodule GeoLocationServiceWeb.PageController do
  use GeoLocationServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
