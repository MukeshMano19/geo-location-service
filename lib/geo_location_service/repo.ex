defmodule GeoLocationService.Repo do
  use Ecto.Repo,
    otp_app: :geo_location_service,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20
end
