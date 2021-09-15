defmodule GeoLocationService.FileLoader do
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

  def sync_data() do
    {micro_seconds, results} = :timer.tc(fn -> start_import() end)

    statistics = %{
      time_taken: micro_seconds / 1_000_000,
      total_entries: get_sum(results, :total),
      accepted: get_sum(results, :accepted),
      discarded: get_sum(results, :discarded)
    }

    IO.inspect("----------------- Result ----------------")
    IO.inspect(statistics, label: "Statistics")
    IO.inspect("-----------------------------------------")
  end

  def start_import() do
    File.stream!(@file_path)
    |> get_records_as_map
    |> Enum.reduce([], fn batch, acc ->
      result = dump_data_to_db(batch)
      acc ++ [result]
    end)
  end

  @doc """
  Returns the list of datasets.

  ## Examples

      iex> list_datasets()
      [%Dataset{}, ...]

  """
  defp get_records_as_map(content) do
    {header, data_lines} = get_header_and_data(content)

    Enum.map(data_lines, fn data_line -> Enum.zip(header, data_line) |> Enum.into(%{}) end)
    |> Enum.chunk_every(@batch_size)
  end

  @doc """
  Returns the list of datasets.

  ## Examples

      iex> list_datasets()
      [%Dataset{}, ...]

  """

  defp get_header_and_data(content) do
    content_lines =
      content
      |> Stream.map(&String.trim(&1))
      |> Stream.filter(&(String.length(&1) != 0))
      |> Stream.map(&String.split(&1, ","))
      |> Enum.to_list()

    [header | data_lines] = content_lines
    {header, data_lines}
  end

  defp dump_data_to_db(datasets) do
    transaction = %{
      multi: Ecto.Multi.new(),
      results: %{total: length(datasets), accepted: 0, discarded: 0}
    }

    updated_transaction =
      datasets
      |> Enum.with_index()
      |> Enum.reduce(transaction, fn {set, idx}, %{multi: multi_acc, results: results} = trns ->
        changeset = %Dataset{} |> Dataset.changeset(parse_data(set))

        case changeset do
          %{valid?: true} ->
            %{
              trns
              | multi:
                  Ecto.Multi.insert(multi_acc, {:insert, idx}, changeset,
                    on_conflict: :replace_all,
                    conflict_target: :ip_address
                  ),
                results: Map.put(results, :accepted, results.accepted + 1)
            }

          _ ->
            %{
              trns
              | multi: multi_acc,
                results: Map.put(results, :discarded, results.discarded + 1)
            }
        end
      end)

    Repo.transaction(updated_transaction.multi)
    updated_transaction.results
  end

  defp parse_data(map) do
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
