#!/bin/bash
# Wrapper script for Figma Context MCP server
# Reads FIGMA_API_KEY from environment or .env file in project root

# Get the script directory and project root (two levels up)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load .env from project root if it exists
if [ -f "$PROJECT_ROOT/.env" ]; then
  export $(grep -v '^#' "$PROJECT_ROOT/.env" | grep FIGMA_API_KEY | xargs)
fi

if [ -z "$FIGMA_API_KEY" ]; then
  echo "Error: FIGMA_API_KEY environment variable is required" >&2
  echo "Set it with: export FIGMA_API_KEY=your_token_here" >&2
  echo "Or add it to your .env file in the project root" >&2
  exit 1
fi

# Change to project root so server can find .env file
cd "$PROJECT_ROOT"

# Run the server in stdio mode with NODE_ENV=cli
exec env NODE_ENV=cli node "$SCRIPT_DIR/dist/bin.js" --stdio

