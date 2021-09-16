defmodule GeoLocationServiceWeb.DatasetController do
  @moduledoc """
    Endpoints for accessing data from datasets table
  """
  use GeoLocationServiceWeb, :controller

  alias GeoLocationService.{Services, Repo}
  alias GeoLocationService.Services.Dataset
  action_fallback GeoLocationServiceWeb.FallbackController

  @doc """
  List all datasets in the datasets table

  ## Examples

    > curl http://localhost:4000/api/datasets
  """
  def index(conn, _params) do
    datasets = Services.list_datasets()
    render(conn, "index.json", datasets: datasets)
  end

  @doc """
  Create a dataset

  ## Examples

    > curl -H "Content-Type: application/json" -X POST -d '{"ip_address":"123.56.34.8","city":"ABC","country":"China","country_code":"XC","latitude":"-455.67","longitude":"34.567","mystery_value":"34534534"}' http://localhost:8080/api/login/
  """
  def create(conn, %{"dataset" => dataset_params}) do
    with {:ok, %Dataset{} = dataset} <- Services.create_dataset(dataset_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.dataset_path(conn, :show, dataset))
      |> render("show.json", dataset: dataset)
    end
  end

  @doc """
  Gets a single dataset.

  ## Examples

    > curl http://localhost:4000/api/datasets/100
    > {"data":{"city":"DuBuquemouth","country":"Nepal","country_code":"SI","id":1,"ip_address":"200.106.141.15",    "latitude":-84.87503094689836,"longitude":7.206435933364332,"mystery_value":7823011346}}
  """
  def show(conn, %{"id" => id}) do
    dataset = Services.get_dataset!(String.to_integer(id))
    render(conn, "show.json", dataset: dataset)
  end

  @doc """
  Create a dataset

  ## Examples

    > curl -H "Content-Type: application/json" -X PUT -d '{"ip_address":"123.56.34.8","city":"ABC","country":"China","country_code":"XC","latitude":"-455.67","longitude":"34.567","mystery_value":"34534534"}' http://localhost:8080/api/login/
  """
  def update(conn, %{"id" => id, "dataset" => dataset_params}) do
    dataset = Services.get_dataset!(id)

    with {:ok, %Dataset{} = dataset} <- Services.update_dataset(dataset, dataset_params) do
      render(conn, "show.json", dataset: dataset)
    end
  end

  @doc """
  Create a dataset

  ## Examples

    > curl -X "DELETE" http://localhost:4000/api/datasets/77230
  """
  def delete(conn, %{"id" => id}) do
    dataset = Services.get_dataset!(id)

    with {:ok, %Dataset{}} <- Services.delete_dataset(dataset) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc """
  Gets a single dataset by ip address.

  ## Examples

    > http://localhost:4000/api/geo_locations/200.106.141.15
    > {"data":{"city":"DuBuquemouth","country":"Nepal","country_code":"SI","id":1,"ip_address":"200.106.141.15",    "latitude":-84.87503094689836,"longitude":7.206435933364332,"mystery_value":7823011346}}
  """
  def get_dataset_by_ip(conn, %{"ip_address" => ip_address}) do
    case Services.get_dataset_by_ip(String.trim(ip_address)) do
      nil -> {:error, :not_found}
      dataset -> render(conn, "show.json", dataset: dataset)
    end
  end

  def home(conn, params) do
    ip_address = get_in(params, ["ip_address"])

    case ip_address in [nil, ""] do
      true ->
        page = Dataset |> Repo.paginate(params)
        render(conn, "index.html", datasets: page.entries, search_term: ip_address, page: page)

      _ ->
        data = Services.get_dataset_by_ip(String.trim(ip_address))
        datasets = if data == nil, do: [], else: [data]

        render(conn, "index.html", datasets: datasets, search_term: ip_address, page: nil)
    end
  end
end
