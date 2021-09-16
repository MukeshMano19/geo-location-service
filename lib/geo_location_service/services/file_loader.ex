defmodule GeoLocationService.Services.FileLoader do
  @moduledoc """
  The Services context.
  """

  alias GeoLocationService.Repo
  alias GeoLocationService.Services.Dataset

  @file_path "data_files/datasets.csv"
  @batch_size 50000

  @doc """
  Returns the list of datasets.

  ## Examples

      iex> list_datasets()
      [%Dataset{}, ...]

  """

  def sync_data(file \\ @file_path) do
    {micro_seconds, results} = :timer.tc(fn -> start_import(file) end)

    statistics = %{
      time_taken: micro_seconds / 1_000_000,
      total_entries: get_sum(results, :total),
      accepted: get_sum(results, :accepted),
      discarded: get_sum(results, :discarded)
    }

    # IO.inspect(statistics, label: "Statistics")

    {:ok, statistics}
  end

  defp start_import(file) do
    File.stream!(file)
    |> get_records_as_map
    |> Enum.chunk_every(@batch_size)
    |> Enum.reduce([], fn batch, acc ->
      {:ok, transactions} = dump_data_to_db(batch)
      total = length(batch)

      # Eventhough Repo.transaction handled unique constrains, still it'll returns response including dublicates.
      # In order to count the exact count which reflected on the table we used Enum.uniq options to get the exact count. 
      accepted = Enum.uniq_by(transactions, fn {_, v} -> v.ip_address end) |> length
      discarded = total - accepted

      acc ++ [%{total: total, accepted: accepted, discarded: discarded}]
    end)
  end

  @doc """
  Returns the list of datasets.

  ## Examples

      iex> list_datasets()
      [%Dataset{}, ...]

  """
  def get_records_as_map(content) do
    {header, data_lines} = get_header_and_data(content)

    Enum.map(data_lines, fn data_line -> Enum.zip(header, data_line) |> Enum.into(%{}) end)
  end

  @doc """
  Returns the list of datasets.

  ## Examples

      iex> list_datasets()
      [%Dataset{}, ...]

  """

  def get_header_and_data(content) do
    content_lines =
      content
      |> Stream.map(&String.trim(&1))
      |> Stream.filter(&(String.length(&1) != 0))
      |> Stream.map(&String.split(&1, ","))
      |> Enum.to_list()

    [header | data_lines] = content_lines
    {header, data_lines}
  end

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

  def parse_data(map) do
    [{"latitude", Float}, {"longitude", Float}, {"mystery_value", Integer}]
    |> Enum.reduce(map, fn {field, type}, acc ->
      case type.parse(map[field]) do
        {v, _} -> Map.put(acc, field, v)
        _ -> Map.put(acc, field, nil)
      end
    end)
  end

  defp get_sum(entries, key), do: Enum.map(entries, &Map.get(&1, key, 0)) |> Enum.sum()
end
