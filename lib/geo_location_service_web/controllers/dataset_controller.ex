defmodule GeoLocationServiceWeb.DatasetController do
  use GeoLocationServiceWeb, :controller

  alias GeoLocationService.Services
  alias GeoLocationService.Services.Dataset

  action_fallback GeoLocationServiceWeb.FallbackController

  def index(conn, _params) do
    datasets = Services.list_datasets()
    render(conn, "index.json", datasets: datasets)
  end

  def create(conn, %{"dataset" => dataset_params}) do
    with {:ok, %Dataset{} = dataset} <- Services.create_dataset(dataset_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.dataset_path(conn, :show, dataset))
      |> render("show.json", dataset: dataset)
    end
  end

  def show(conn, %{"id" => id}) do
    dataset = Services.get_dataset!(id)
    render(conn, "show.json", dataset: dataset)
  end

  def update(conn, %{"id" => id, "dataset" => dataset_params}) do
    dataset = Services.get_dataset!(id)

    with {:ok, %Dataset{} = dataset} <- Services.update_dataset(dataset, dataset_params) do
      render(conn, "show.json", dataset: dataset)
    end
  end

  def delete(conn, %{"id" => id}) do
    dataset = Services.get_dataset!(id)

    with {:ok, %Dataset{}} <- Services.delete_dataset(dataset) do
      send_resp(conn, :no_content, "")
    end
  end

  def page_index(conn, params) do
    ip_address = get_in(params, ["ip_address"])

    datasets =
      case ip_address in [nil, ""] do
        true ->
          Services.list_datasets() |> Enum.take(100)

        _ ->
          data = Services.get_geo_data_by_ip(ip_address)
          if data == nil, do: [], else: [data]
      end

    render(conn, "index.html", datasets: datasets, search_term: ip_address)
  end

  def get_geo_data_by_ip(conn, %{"ip_address" => ip_address}) do
    case Services.get_geo_data_by_ip(ip_address) do
      nil -> {:error, :not_found}
      dataset -> render(conn, "show.json", dataset: dataset)
    end
  end
end
