defmodule GeoLocationService.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :geo_location_service,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  def init(_, config) do
    config =
      case Keyword.get(config, :hostname) do
        "db" ->
          config
          |> Keyword.put(:username, System.get_env("PGUSER"))
          |> Keyword.put(:password, System.get_env("PGPASSWORD"))
          |> Keyword.put(:database, System.get_env("PGDATABASE"))
          |> Keyword.put(:hostname, System.get_env("PGHOST"))
          |> Keyword.put(:port, System.get_env("PGPORT") |> String.to_integer())

        _ ->
          config
      end

    {:ok, config}
  end
end
