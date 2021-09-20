defmodule GeoLocationService.Services.SchemalessFileLoader do
  @moduledoc """
    The SchemalessFileLoader module helps to import the csv file.

    It takes maximum 100 seconds to insert 1M records.

    Here we used Schema-less queries (i.e, Ecto.Multi.insert_all).
    It's designed for more direct operations with the database and it's not operate over changesets. 
    So we added the custom validations for validating the records. 
    And it's suitable for handling huge csv files.
  """

  alias GeoLocationService.Repo
  alias GeoLocationService.Services.Dataset

  @file_path "data_files/datasets.csv"
  @batch_size 5000
  @valid_ip_regex ~r/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/

  @doc """
  Import the csv file and returns the statistics of the import status.

  ## Examples
      
      iex> sync_data("data_files/datasets.csv")
      Statistics: %{
        processed_time: 12.56,
        processed: 100,
        accepted: 70,
        discarded: 30
      }

  """
  @spec sync_data(String.t()) :: {:ok, map}
  def sync_data(file \\ @file_path) do
    {micro_seconds, result} = :timer.tc(fn -> get_records_as_map(file) |> dump_data_to_db end)

    {:ok, Map.put(result, :processed_time, micro_seconds / 1_000_000)}
  end

  @doc """
  Parse csv file and returns csv records as map.

  ## Examples

      iex> get_records_as_map("data_files/datasets.csv")
      [%{ip_address: "12.56.34.6", city: "ooty", ...}, ...]

  """
  @spec get_records_as_map(String.t()) :: list
  def get_records_as_map(file) do
    IO.inspect("Parcing the CSV file ...")
    {header, data_lines} = get_header_and_data(file)

    data_lines
    |> Stream.map(&(Enum.zip(header, &1) |> Enum.into(%{})))
    |> Stream.map(
      &for {key, val} <- &1, into: %{}, do: {String.to_atom(key), parse_data(key, val)}
    )
    |> Enum.to_list()
  end

  @doc """
  Parse csv file and returns header and data lines separately.

  ## Examples

      iex> get_header_and_data("data_files/datasets.csv")
      {["ip_address", "city", "country", ...], ["123, 45, 56,3", "ooty", "india", .., ....]}

  """
  @spec get_header_and_data(String.t()) :: {list, list}
  def get_header_and_data(file) do
    content_lines =
      File.stream!(file)
      |> Stream.map(&String.trim(&1))
      |> Stream.filter(&(String.length(&1) != 0))
      |> Stream.map(&String.split(&1, ","))
      |> Enum.to_list()

    [header | data_lines] = content_lines
    {header, data_lines}
  end

  @doc """
  Insert list of valid datasets and returns success Repo.transaction response.
  Invalid records are discarded.

  ## Examples

      iex> datasets = [%{ip_address: "234.54.7.34", city: "ooty", country: "India", country_code: "IN", latitude: "123.456", longitude: "-44.532", mystery_value: "23234342"}, ...]  
      iex> dump_data_to_db(datasets)
      %{
        processed: 100,
        accepted: 70,
        discarded: 30
      }                                                       
  """
  @spec dump_data_to_db(list) :: map
  def dump_data_to_db(datasets) do
    accepted =
      datasets
      |> validate_and_make_batch
      |> Enum.reduce(0, fn batch, acc ->
        {_, %{insert_all: {total_inserted, _}}} =
          Ecto.Multi.new()
          |> Ecto.Multi.insert_all(:insert_all, Dataset, batch,
            on_conflict: :replace_all,
            conflict_target: :ip_address
          )
          |> Repo.transaction(timeout: :infinity)

        acc + total_inserted
      end)

    processed = length(datasets)
    %{processed: processed, accepted: accepted, discarded: processed - accepted}
  end

  defp validate_and_make_batch(datasets) do
    IO.inspect("Validating the records ...")

    datasets
    |> Stream.uniq_by(& &1.ip_address)
    |> Stream.filter(&(validate_ip(&1) != false))
    |> Stream.filter(&(validate_nil(&1) != false))
    |> Enum.to_list()
    |> Enum.chunk_every(@batch_size)
  end

  # IP Address Validations
  @doc """
  Validate the given ip address from the map and return map or false.

  ## Examples

      iex> validate_ip(%{ip_address: "234.54.7.34", mystery_value: "23234342"})
      %{ip_address: "234.54.7.34", mystery_value: "23234342"}

      iex> validate_ip(%{ip_address: "234.545.7.345", mystery_value: "23234342"})
      false

  """
  def validate_ip(%{ip_address: nil}), do: false

  def validate_ip(%{ip_address: ip} = data),
    do: if(Regex.match?(@valid_ip_regex, ip) == true, do: data, else: false)

  # Nil value Validations
  @doc """
  Validate nil values from the map and returns map or false.

  ## Examples

      iex> validate_nil(%{ip_address: "234.54.7.34", mystery_value: "23234342"})
      %{ip_address: "234.54.7.34", mystery_value: "23234342"}

      iex> validate_nil(%{ip_address: "234.547.7.344", longitude: nil, mystery_value: nil})
      false

  """
  def validate_nil(data), do: if(nil in Map.values(data), do: false, else: data)

  # Parse Key value pair
  defp parse_data(key, val) when key in ["latitude", "longitude"] and is_binary(val) do
    case Float.parse(String.trim(val)) do
      {v, _} -> v
      _ -> nil
    end
  end

  defp parse_data(key, val) when key == "mystery_value" and is_binary(val) do
    case Integer.parse(String.trim(val)) do
      {v, _} -> v
      _ -> nil
    end
  end

  defp parse_data(_key, val) when is_binary(val) do
    trimmed = String.trim(val)
    if String.length(trimmed) != 0, do: trimmed, else: nil
  end

  defp parse_data(_, _), do: nil
end
