defmodule GeoLocationService.Repo.Migrations.CreateDatasets do
  use Ecto.Migration

  def change do
    create table(:datasets) do
      add :ip_address, :string
      add :country_code, :string
      add :country, :string
      add :city, :string
      add :latitude, :float
      add :longitude, :float
      add :mystery_value, :bigint

      timestamps()
    end

    create unique_index(:datasets, [:ip_address])
  end
end
