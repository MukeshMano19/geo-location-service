defmodule GeoLocationService.SchemalessFileLoaderTest do
  use GeoLocationService.DataCase
  alias GeoLocationService.Services.SchemalessFileLoader

  @test_file_path "data_files/test-datasets.csv"

  @attrs %{
    city: "New Neva",
    country: "Nicaragua",
    country_code: "CZ",
    ip_address: "123.67.98.11",
    latitude: -68.31023296602508,
    longitude: -37.62435199624531,
    mystery_value: 7_301_823_115
  }

  @invalid_attrs %{
    city: nil,
    country: nil,
    country_code: nil,
    ip_address: nil,
    latitude: nil,
    longitude: nil,
    mystery_value: nil
  }

  describe "Fill Loader using Schemaless query method" do
    test "sync_data/1 with file path to import csv file and save it to the database" do
      assert {:ok, statistics} = SchemalessFileLoader.sync_data(@test_file_path)
      assert statistics.processed == 54
      assert statistics.accepted == 44
      assert statistics.discarded == 10
      assert statistics.processed_time != nil
    end

    test "validate_ip/1 with the valid ip address in the map and returns map" do
      map = SchemalessFileLoader.validate_ip(@attrs)
      assert map.ip_address == "123.67.98.11"
    end

    test "validate_ip/1 with the invalid ip address in the map and returns false" do
      invalid_map = Map.put(@attrs, :ip_address, "123.567.53.568")
      assert false == SchemalessFileLoader.validate_ip(invalid_map)
    end

    test "validate_nil/1 with the valid map and returns map" do
      map = SchemalessFileLoader.validate_nil(@attrs)
      assert is_map(map) == true
    end

    test "validate_nil/1 with the map having nil values and returns false" do
      assert false == SchemalessFileLoader.validate_nil(@invalid_attrs)
    end
  end
end
