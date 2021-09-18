defmodule GeoLocationService.FileLoaderTest do
  use GeoLocationService.DataCase
  alias GeoLocationService.Services.{FileLoader, Dataset}

  @test_file_path "data_files/test-datasets.csv"

  @attrs %{
    "city" => "New Neva",
    "country" => "Nicaragua",
    "country_code" => "CZ",
    "ip_address" => "123.67.98.11",
    "latitude" => "-68.31023296602508",
    "longitude" => "-37.62435199624531",
    "mystery_value" => "7301823115"
  }

  describe "Fill Loader" do
    test "sync_data/1 with file path to import csv file and save it to the database" do
      assert {:ok, statistics} = FileLoader.sync_data(@test_file_path)
      assert statistics.total_entries == 1000
      assert statistics.accepted == 863
      assert statistics.discarded == 137
      assert statistics.time_taken != nil
    end

    test "get_header_and_data/1 with file path to read the csv file and returns header and datasets separately" do
      assert {header, datasets} = FileLoader.get_header_and_data(@test_file_path)
      assert length(header) == 7
      assert is_list(datasets) == true
    end

    test "get_records_as_map/1 with file path to read the csv file and returns header and datasets separately" do
      list_of_maps = FileLoader.get_records_as_map(@test_file_path)
      assert hd(list_of_maps) |> is_map == true
    end

    test "parse_data/1 with attrs of all string value and returns converted selected fields of map" do
      converted_map = FileLoader.parse_data(@attrs)
      assert converted_map["latitude"] == -68.31023296602508
      assert is_float(converted_map["latitude"]) == true
      assert converted_map["longitude"] == -37.62435199624531
      assert is_float(converted_map["longitude"]) == true
      assert converted_map["mystery_value"] == 7_301_823_115
      assert is_integer(converted_map["mystery_value"]) == true
    end

    test "dump_data_to_db/1 with list of data to do the transactions and returns transaction result" do
      list_of_maps = FileLoader.get_records_as_map(@test_file_path)
      assert {:ok, transactions} = FileLoader.dump_data_to_db(list_of_maps)
      assert {_key, %Dataset{}} = Enum.random(transactions)
    end
  end
end
