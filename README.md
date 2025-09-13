[![Hex.pm](https://img.shields.io/hexpm/v/mime_description)](https://hex.pm/packages/mime_description)
[![Hexdocs.pm](https://img.shields.io/badge/docs-hexdocs.pm-purple)](https://hexdocs.pm/mime_description)
[![Github.com](https://github.com/neilberkman/mime_description/actions/workflows/elixir.yml/badge.svg)](https://github.com/neilberkman/mime_description/actions)

# MimeDescription

Human-friendly MIME type descriptions for Elixir.

This library provides embedded MIME type descriptions sourced from the [freedesktop.org shared-mime-info database](https://gitlab.freedesktop.org/xdg/shared-mime-info). The data is compiled directly into the library at build time, so no runtime fetching is required.

## Installation

Add `mime_description` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mime_description, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Get description for a MIME type
MimeDescription.get("application/pdf")
#=> {:ok, "PDF document"}

MimeDescription.get("text/plain")
#=> {:ok, "plain text document"}

# Handle unknown types
MimeDescription.get("unknown/type")
#=> {:error, :not_found}

# Get with a default fallback
MimeDescription.get_with_default("unknown/type", "Unknown file")
#=> "Unknown file"

# Raise if not found
MimeDescription.get!("application/pdf")
#=> "PDF document"
```

## How It Works

Unlike runtime-based solutions, MimeDescription embeds the MIME type database directly into your compiled application. This means:

- **No network requests** at runtime
- **No file I/O** to read external databases
- **Fast lookups** from an in-memory Elixir map
- **No dependencies** on system MIME databases

The MIME data is sourced from the authoritative freedesktop.org shared-mime-info database and is automatically updated weekly via GitHub Actions.

## Updating the MIME Database

The library includes a Mix task to update the embedded MIME data:

```bash
# Check for updates and regenerate if needed
mix mime_description.generate

# Force regeneration
mix mime_description.generate --force
```

This task:

1. Checks if the upstream database has changed (using ETags)
2. Downloads the latest XML data if needed
3. Parses and generates an Elixir module with the embedded data
4. The generated module is compiled into your application

## Automated Updates

The MIME database is automatically updated weekly via GitHub Actions. The workflow:

- Runs every Sunday at 02:00 UTC
- Checks for updates from freedesktop.org
- Regenerates the data module if changes are detected
- Commits the updates back to the repository

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

## Credits

MIME type descriptions are sourced from the [freedesktop.org shared-mime-info database](https://gitlab.freedesktop.org/xdg/shared-mime-info).
