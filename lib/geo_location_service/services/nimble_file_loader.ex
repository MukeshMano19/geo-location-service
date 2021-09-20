defmodule GeoLocationService.Services.NimbleFileLoader do
  @moduledoc """
    Here we used Nimble CSV parser for parsing the CSV file.
    It reduces the initial parsing time.

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

  def import() do
    {micro_seconds, result} = :timer.tc(fn -> parse_file() |> dump_data_to_db end)

    {:ok, Map.put(result, :processed_time, micro_seconds / 1_000_000)}
  end

  def parse_file() do
    @file_path
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.map(fn [
                       ip_address,
                       country_code,
                       country,
                       city,
                       latitude,
                       longitude,
                       mystery_value
                     ] ->
      %{
        ip_address: parse_data("", ip_address),
        country_code: parse_data("", country_code),
        city: parse_data("", city),
        country: parse_data("", country),
        latitude: parse_data("latitude", latitude),
        longitude: parse_data("longitude", longitude),
        mystery_value: parse_data("mystery_value", mystery_value)
      }
    end)
    |> Enum.to_list()
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
