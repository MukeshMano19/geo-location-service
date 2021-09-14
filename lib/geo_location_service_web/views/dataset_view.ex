defmodule GeoLocationServiceWeb.DatasetView do
  use GeoLocationServiceWeb, :view
  alias GeoLocationServiceWeb.DatasetView

  def render("index.json", %{datasets: datasets}) do
    %{data: render_many(datasets, DatasetView, "dataset.json")}
  end

  def render("show.json", %{dataset: dataset}) do
    %{data: render_one(dataset, DatasetView, "dataset.json")}
  end

  def render("dataset.json", %{dataset: dataset}) do
    %{id: dataset.id,
      ip_address: dataset.ip_address,
      country_code: dataset.country_code,
      country: dataset.country,
      city: dataset.city,
      latitude: dataset.latitude,
      longitude: dataset.longitude,
      mystery_value: dataset.mystery_value}
  end
end
