defmodule GeoLocationServiceWeb.DatasetControllerTest do
  use GeoLocationServiceWeb.ConnCase

  alias GeoLocationService.Services
  alias GeoLocationService.Services.Dataset

  @create_attrs %{
    city: "some city",
    country: "some country",
    country_code: "some country_code",
    ip_address: "some ip_address",
    latitude: 120.5,
    longitude: 120.5,
    mystery_value: 42
  }
  @update_attrs %{
    city: "some updated city",
    country: "some updated country",
    country_code: "some updated country_code",
    ip_address: "some updated ip_address",
    latitude: 456.7,
    longitude: 456.7,
    mystery_value: 43
  }
  @invalid_attrs %{city: nil, country: nil, country_code: nil, ip_address: nil, latitude: nil, longitude: nil, mystery_value: nil}

  def fixture(:dataset) do
    {:ok, dataset} = Services.create_dataset(@create_attrs)
    dataset
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all datasets", %{conn: conn} do
      conn = get(conn, Routes.dataset_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create dataset" do
    test "renders dataset when data is valid", %{conn: conn} do
      conn = post(conn, Routes.dataset_path(conn, :create), dataset: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.dataset_path(conn, :show, id))

      assert %{
               "id" => id,
               "city" => "some city",
               "country" => "some country",
               "country_code" => "some country_code",
               "ip_address" => "some ip_address",
               "latitude" => 120.5,
               "longitude" => 120.5,
               "mystery_value" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.dataset_path(conn, :create), dataset: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update dataset" do
    setup [:create_dataset]

    test "renders dataset when data is valid", %{conn: conn, dataset: %Dataset{id: id} = dataset} do
      conn = put(conn, Routes.dataset_path(conn, :update, dataset), dataset: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.dataset_path(conn, :show, id))

      assert %{
               "id" => id,
               "city" => "some updated city",
               "country" => "some updated country",
               "country_code" => "some updated country_code",
               "ip_address" => "some updated ip_address",
               "latitude" => 456.7,
               "longitude" => 456.7,
               "mystery_value" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, dataset: dataset} do
      conn = put(conn, Routes.dataset_path(conn, :update, dataset), dataset: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete dataset" do
    setup [:create_dataset]

    test "deletes chosen dataset", %{conn: conn, dataset: dataset} do
      conn = delete(conn, Routes.dataset_path(conn, :delete, dataset))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.dataset_path(conn, :show, dataset))
      end
    end
  end

  defp create_dataset(_) do
    dataset = fixture(:dataset)
    %{dataset: dataset}
  end
end
