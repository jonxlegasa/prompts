#!/usr/bin/env bash
echo "Building prompts from source..."
bash utils/compose.sh

echo "Stowing prompts..."
stow --adopt claude opencode

echo "Done."
