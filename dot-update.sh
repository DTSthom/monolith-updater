#!/bin/bash
# .update command - Monolith System Update Manager
# Entry point wrapper that calls the main implementation

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call the main implementation from the same directory
"${SCRIPT_DIR}/update-production.sh" "$@"