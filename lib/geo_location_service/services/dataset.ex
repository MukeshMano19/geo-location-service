defmodule GeoLocationService.Services.Dataset do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @valid_ip_regex ~r/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/

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
    |> cast(attrs, [
      :ip_address,
      :country_code,
      :country,
      :city,
      :latitude,
      :longitude,
      :mystery_value
    ])
    |> validate_required([
      :ip_address,
      :country_code,
      :country,
      :city,
      :latitude,
      :longitude,
      :mystery_value
    ])
    |> unique_constraint(:ip_address, message: "IP Address must be unique!")
    |> validate_ip_address()
  end

  defp validate_ip_address(changeset) do
    if changeset.valid? do
      ip = get_field(changeset, :ip_address)

      if Regex.match?(@valid_ip_regex, ip) do
        changeset
      else
        add_error(changeset, :ip_address, "Not a valid ip address")
      end
    else
      changeset
    end
  end
end
