defmodule GeoLocationService.Services do
  @moduledoc """
  The Services context. This module has functionalities to access datasets. 
  """

  import Ecto.Query, warn: false
  alias GeoLocationService.Repo

  alias GeoLocationService.Services.Dataset

  @doc """
  Returns the list of datasets.

  ## Examples

      iex> list_datasets()
      [%Dataset{}, ...]

  """
  def list_datasets do
    Repo.all(Dataset)
  end

  @doc """
  Gets a single dataset.

  Raises `Ecto.NoResultsError` if the Dataset does not exist.

  ## Examples

      iex> get_dataset!(123)
      %Dataset{}

      iex> get_dataset!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dataset!(id), do: Repo.get!(Dataset, id)

  @doc """
  Creates a dataset.

  ## Examples

      iex> create_dataset(%{field: value})
      {:ok, %Dataset{}}

      iex> create_dataset(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_dataset(attrs \\ %{}) do
    %Dataset{}
    |> Dataset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dataset.

  ## Examples

      iex> update_dataset(dataset, %{field: new_value})
      {:ok, %Dataset{}}

      iex> update_dataset(dataset, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dataset(%Dataset{} = dataset, attrs) do
    dataset
    |> Dataset.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dataset.

  ## Examples

      iex> delete_dataset(dataset)
      {:ok, %Dataset{}}

      iex> delete_dataset(dataset)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dataset(%Dataset{} = dataset) do
    Repo.delete(dataset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dataset changes.

  ## Examples

      iex> change_dataset(dataset)
      %Ecto.Changeset{data: %Dataset{}}

  """
  def change_dataset(%Dataset{} = dataset, attrs \\ %{}) do
    Dataset.changeset(dataset, attrs)
  end

  @doc """
  Gets a single dataset with the given ip address.

  Raises `Ecto.NoResultsError` if the Dataset does not exist.

  ## Examples

      iex> get_dataset_by_ip("123.67.23.2")
      %Dataset{}

      iex> get_dataset_by_ip("123.67.2.24")
      ** (Ecto.NoResultsError)

  """
  def get_dataset_by_ip(ip_address), do: Repo.get_by(Dataset, ip_address: ip_address)
end
