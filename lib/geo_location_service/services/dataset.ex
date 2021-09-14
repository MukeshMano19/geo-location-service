defmodule GeoLocationService.Services.Dataset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "datasets" do
    field :city, :string
    field :country, :string
    field :country_code, :string
    field :ip_address, :string
    field :latitude, :float
    field :longitude, :float
    field :mystery_value, :integer

    timestamps()
  end

  @doc false
  def changeset(dataset, attrs) do
    dataset
    |> cast(attrs, [:ip_address, :country_code, :country, :city, :latitude, :longitude, :mystery_value])
    |> validate_required([:ip_address, :country_code, :country, :city, :latitude, :longitude, :mystery_value])
  end
end
