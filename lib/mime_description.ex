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

      # Handle MIME types with parameters (charset, boundary, etc.)
      MimeDescription.get_from_header("text/plain; charset=utf-8")
      #=> {:ok, "Plain text document"}

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
      {:ok, "Plain text document"}

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
  Get the human-friendly description for a MIME type from a raw header value.

  This function handles MIME types that may include parameters like charset,
  boundary, etc. It extracts the base MIME type and looks up its description.

  ## Examples

      iex> MimeDescription.get_from_header("text/plain; charset=utf-8")
      {:ok, "Plain text document"}

      iex> MimeDescription.get_from_header("application/pdf; name=document.pdf")
      {:ok, "PDF document"}

      iex> MimeDescription.get_from_header("text/html;charset=ISO-8859-1")
      {:ok, "HTML document"}

      iex> MimeDescription.get_from_header("multipart/form-data; boundary=----WebKitFormBoundary")
      {:ok, "multipart message"}

      iex> MimeDescription.get_from_header("unknown/type; param=value")
      {:error, :not_found}
  """
  @spec get_from_header(String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def get_from_header(mime_header) when is_binary(mime_header) do
    mime_header
    |> extract_mime_type()
    |> get()
  end

  @doc """
  Get the human-friendly description for a MIME type from a raw header value,
  returning the cleaned MIME type as a fallback if not found.

  This is useful when you want to display something reasonable even for unknown types.

  ## Examples

      iex> MimeDescription.get_from_header_with_fallback("text/plain; charset=utf-8")
      "Plain text document"

      iex> MimeDescription.get_from_header_with_fallback("application/x-custom; param=value")
      "application/x-custom"

      iex> MimeDescription.get_from_header_with_fallback("unknown/type; charset=utf-8", "Unknown file")
      "Unknown file"
  """
  @spec get_from_header_with_fallback(String.t(), String.t() | nil) :: String.t()
  def get_from_header_with_fallback(mime_header, default \\ nil) when is_binary(mime_header) do
    cleaned_mime = extract_mime_type(mime_header)

    case get(cleaned_mime) do
      {:ok, description} -> description
      {:error, :not_found} -> default || cleaned_mime
    end
  end

  @doc """
  Extract the base MIME type from a header value, removing any parameters.

  ## Examples

      iex> MimeDescription.extract_mime_type("text/plain; charset=utf-8")
      "text/plain"

      iex> MimeDescription.extract_mime_type("application/pdf;name=document.pdf")
      "application/pdf"

      iex> MimeDescription.extract_mime_type("  text/html ; charset=ISO-8859-1  ")
      "text/html"
  """
  @spec extract_mime_type(String.t()) :: String.t()
  def extract_mime_type(mime_header) when is_binary(mime_header) do
    mime_header
    |> String.split(";")
    |> List.first()
    |> Kernel.||("")
    |> String.trim()
    |> String.downcase()
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
