defmodule MimeDescription do
  @moduledoc """
  Human-friendly MIME type descriptions for Elixir.

  This library provides embedded MIME type descriptions sourced from the 
  freedesktop.org shared-mime-info database. The data is compiled directly
  into the library, so no runtime fetching is required.

  ## Usage

      # Get description for a specific MIME type
      MimeDescription.get("application/pdf")
      #=> {:ok, "PDF document"}

      # Get description with fallback
      MimeDescription.get("unknown/type")
      #=> {:error, :not_found}

  ## Updating the MIME database

  The MIME data is embedded at compile time. To update it with the latest
  from freedesktop.org, run:

      mix mime_description.generate

  This task will check if the remote database has changed and regenerate
  the embedded data module if needed.
  """

  @doc """
  Get the human-friendly description for a MIME type.

  Returns `{:ok, description}` if found, or `{:error, :not_found}` if not found.

  ## Examples

      iex> MimeDescription.get("application/pdf")
      {:ok, "PDF document"}

      iex> MimeDescription.get("text/plain")
      {:ok, "plain text document"}

      iex> MimeDescription.get("unknown/type")
      {:error, :not_found}
  """
  @spec get(String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def get(mime_type) when is_binary(mime_type) do
    case MimeDescription.Data.get(mime_type) do
      nil -> {:error, :not_found}
      description -> {:ok, description}
    end
  end

  @doc """
  Get the human-friendly description for a MIME type, raising if not found.

  ## Examples

      iex> MimeDescription.get!("application/pdf")
      "PDF document"

      iex> MimeDescription.get!("unknown/type")
      ** (KeyError) MIME type not found: "unknown/type"
  """
  @spec get!(String.t()) :: String.t()
  def get!(mime_type) when is_binary(mime_type) do
    case get(mime_type) do
      {:ok, description} -> description
      {:error, :not_found} -> raise KeyError, "MIME type not found: #{inspect(mime_type)}"
    end
  end

  @doc """
  Get the description for a MIME type with a default fallback.

  ## Examples

      iex> MimeDescription.get_with_default("application/pdf", "Unknown")
      "PDF document"

      iex> MimeDescription.get_with_default("unknown/type", "Unknown")
      "Unknown"
  """
  @spec get_with_default(String.t(), String.t()) :: String.t()
  def get_with_default(mime_type, default \\ "Unknown file type") when is_binary(mime_type) and is_binary(default) do
    case get(mime_type) do
      {:ok, description} -> description
      {:error, :not_found} -> default
    end
  end
end
