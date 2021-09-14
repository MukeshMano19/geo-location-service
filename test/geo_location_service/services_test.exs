defmodule GeoLocationService.ServicesTest do
  use GeoLocationService.DataCase

  alias GeoLocationService.Services

  describe "datasets" do
    alias GeoLocationService.Services.Dataset

    @valid_attrs %{city: "some city", country: "some country", country_code: "some country_code", ip_address: "some ip_address", latitude: 120.5, longitude: 120.5, mystery_value: 42}
    @update_attrs %{city: "some updated city", country: "some updated country", country_code: "some updated country_code", ip_address: "some updated ip_address", latitude: 456.7, longitude: 456.7, mystery_value: 43}
    @invalid_attrs %{city: nil, country: nil, country_code: nil, ip_address: nil, latitude: nil, longitude: nil, mystery_value: nil}

    def dataset_fixture(attrs \\ %{}) do
      {:ok, dataset} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Services.create_dataset()

      dataset
    end

    test "list_datasets/0 returns all datasets" do
      dataset = dataset_fixture()
      assert Services.list_datasets() == [dataset]
    end

    test "get_dataset!/1 returns the dataset with given id" do
      dataset = dataset_fixture()
      assert Services.get_dataset!(dataset.id) == dataset
    end

    test "create_dataset/1 with valid data creates a dataset" do
      assert {:ok, %Dataset{} = dataset} = Services.create_dataset(@valid_attrs)
      assert dataset.city == "some city"
      assert dataset.country == "some country"
      assert dataset.country_code == "some country_code"
      assert dataset.ip_address == "some ip_address"
      assert dataset.latitude == 120.5
      assert dataset.longitude == 120.5
      assert dataset.mystery_value == 42
    end

    test "create_dataset/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Services.create_dataset(@invalid_attrs)
    end

    test "update_dataset/2 with valid data updates the dataset" do
      dataset = dataset_fixture()
      assert {:ok, %Dataset{} = dataset} = Services.update_dataset(dataset, @update_attrs)
      assert dataset.city == "some updated city"
      assert dataset.country == "some updated country"
      assert dataset.country_code == "some updated country_code"
      assert dataset.ip_address == "some updated ip_address"
      assert dataset.latitude == 456.7
      assert dataset.longitude == 456.7
      assert dataset.mystery_value == 43
    end

    test "update_dataset/2 with invalid data returns error changeset" do
      dataset = dataset_fixture()
      assert {:error, %Ecto.Changeset{}} = Services.update_dataset(dataset, @invalid_attrs)
      assert dataset == Services.get_dataset!(dataset.id)
    end

    test "delete_dataset/1 deletes the dataset" do
      dataset = dataset_fixture()
      assert {:ok, %Dataset{}} = Services.delete_dataset(dataset)
      assert_raise Ecto.NoResultsError, fn -> Services.get_dataset!(dataset.id) end
    end

    test "change_dataset/1 returns a dataset changeset" do
      dataset = dataset_fixture()
      assert %Ecto.Changeset{} = Services.change_dataset(dataset)
    end
  end
end
