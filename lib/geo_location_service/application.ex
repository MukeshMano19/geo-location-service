defmodule GeoLocationService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      GeoLocationService.Repo,
      # Start the Telemetry supervisor
      GeoLocationServiceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GeoLocationService.PubSub},
      # Start the Endpoint (http/https)
      GeoLocationServiceWeb.Endpoint,
      # Start a worker by calling: GeoLocationService.Worker.start_link(arg)
      # {GeoLocationService.Worker, arg}
      GeoLocationService.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GeoLocationService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GeoLocationServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
