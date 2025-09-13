defmodule Mix.Tasks.MimeDescription.Generate do
  @shortdoc "Generate embedded MIME description data from freedesktop.org"

  @moduledoc """
  Generates or updates the embedded MIME description data module.

  This task fetches the latest MIME type descriptions from the freedesktop.org
  shared-mime-info database and generates an Elixir module with the data embedded.

  The task uses ETags to check if the remote data has changed since the last
  generation, avoiding unnecessary downloads and regeneration.

  ## Usage

      mix mime_description.generate

  ## Options

    * `--force` - Force regeneration even if the data hasn't changed

  ## Examples

      # Check for updates and regenerate if needed
      mix mime_description.generate

      # Force regeneration
      mix mime_description.generate --force

  """
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [force: :boolean])
    force = Keyword.get(opts, :force, false)

    # Start the application to ensure dependencies are available
    Mix.Task.run("app.start")

    case MimeDescription.Generator.generate(force) do
      :ok ->
        Mix.shell().info("✓ MIME description data generated successfully")

      {:error, reason} ->
        Mix.shell().error("✗ Failed to generate MIME data: #{inspect(reason)}")
        exit({:shutdown, 1})
    end
  end
end
