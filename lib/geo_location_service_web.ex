defmodule GeoLocationServiceWeb do
  @moduledoc false

  def controller do
    quote do
      use Phoenix.Controller, namespace: GeoLocationServiceWeb

      import Plug.Conn
      import GeoLocationServiceWeb.Gettext
      alias GeoLocationServiceWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/geo_location_service_web/templates",
        namespace: GeoLocationServiceWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import GeoLocationServiceWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import GeoLocationServiceWeb.ErrorHelpers
      import GeoLocationServiceWeb.Gettext
      alias GeoLocationServiceWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
