defmodule GeoLocationService.Services.FileLoader do
  @moduledoc """
    The Fileloader module helps to import the csv file.
  """

  alias GeoLocationService.Repo
  alias GeoLocationService.Services.Dataset

  @file_path "data_files/test-datasets.csv"
  @batch_size 25000

  @doc """
  Import the csv file and returns the statistics of the import status.
  
  ## Examples
      
      iex> sync_data("data_files/datasets.csv")
      Statistics: %{
        time_taken: 12.56,
        total_entries: 100,
        accepted: 70,
        discarded: 30
      }
  
  """
  @spec sync_data(String.t()) :: {:ok, map}
  def sync_data(file \\ @file_path) do
    {micro_seconds, {processed, accepted, discarded}} = :timer.tc(fn -> start_import(file) end)

    statistics = %{
      time_taken: micro_seconds / 1_000_000,
      total_entries: processed,
      accepted: accepted,
      discarded: discarded
    }

    {:ok, statistics}
  end

  @doc false
  @spec start_import(String.t()) :: list
  defp start_import(file) do
    get_records_as_map(file)
    |> Enum.chunk_every(@batch_size)
    |> Enum.reduce({0, 0, 0}, fn batch, {processed, accepted, discarded} ->
      {:ok, transactions} = dump_data_to_db(batch)
      total = length(batch)

      # Eventhough Repo.transaction handled unique constrains, still it'll returns response including dublicates.
      # In order to count the exact count which reflected on the table we used Enum.uniq options to get the exact count. 
      success = Enum.uniq_by(transactions, fn {_, v} -> v.ip_address end) |> length
      filure = total - success

      {processed + total, accepted + success, discarded + filure}
    end)
  end

  @doc """
  Parse csv file and returns csv records as map.
  
  ## Examples
  
      iex> get_records_as_map("data_files/datasets.csv")
      [%{"ip_address" => "12.56.34.6", "city" => "ooty", ...}, ...]
  
  """
  @spec get_records_as_map(String.t()) :: map
  def get_records_as_map(file) do
    {header, data_lines} = get_header_and_data(file)

    Enum.map(data_lines, fn data_line -> Enum.zip(header, data_line) |> Enum.into(%{}) end)
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
  
      iex> datasets = [%{"ip_address" => "234.54.7.34", "city" => "ooty", "country" => "India", "country_code" => "IN", "latitude" => "123.456", "longitude" => "-44.532", "mystery_value" => "23234342"}, ...]  
      iex> dump_data_to_db(datasets)
      {:ok,                                                     
        %{                                                       
          {:insert, 0} => %GeoLocationService.Services.Dataset{  
            __meta__: #Ecto.Schema.Metadata<:loaded, "datasets">,
            city: "ooty",                                        
            country: "India",                                    
            country_code: "IN",                                  
            id: 96564,                                           
            inserted_at: ~N[2021-09-17 04:58:59],                
            ip_address: "234.54.7.34",                           
            latitude: 123.456,                                   
            longitude: -44.532,                                  
            mystery_value: 23234342,                             
            updated_at: ~N[2021-09-17 04:58:59]                  
        },
        ...                                                      
      }}                                                       
  """
  @spec dump_data_to_db(list) :: {:ok, map}
  def dump_data_to_db(datasets) do
    datasets
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {set, idx}, multi ->
      case %Dataset{} |> Dataset.changeset(parse_data(set)) do
        %{valid?: true} = changeset ->
          Ecto.Multi.insert(multi, {:insert, idx}, changeset,
            on_conflict: :replace_all,
            conflict_target: :ip_address
          )

        _ ->
          multi
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Parse the map and returns the converted field values of map.
  Latitude, langitude and mystery_value field values are converted from string to respective formate.  
  
  ## Examples
  
      iex> dataset = %{"ip_address" => "234.54.7.34", "city" => "ooty", "country" => "India", "country_code" => "IN", "latitude" => "123.456", "longitude" => "-44.532", "mystery_value" => "23234342"}
      iex> parse_data(dataset)
      %{"ip_address" => "234.54.7.34", "city" => "ooty", "country" => "India", "country_code" => "IN", "latitude" => 123.456, "longitude" => -44.532, "mystery_value" => 23234342}
  
  """
  @spec parse_data(%{required(String.t()) => String.t()}) :: map
  def parse_data(map) do
    [{"latitude", Float}, {"longitude", Float}, {"mystery_value", Integer}]
    |> Enum.reduce(map, fn {field, type}, acc ->
      case type.parse(map[field]) do
        {v, _} -> Map.put(acc, field, v)
        _ -> Map.put(acc, field, nil)
      end
    end)
  end
end
