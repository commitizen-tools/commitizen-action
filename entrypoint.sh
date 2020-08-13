#!/bin/bash

: "${INPUT_DRY_RUN:=false}"
# : "${INPUT_CHANGELOG:=true}" ignroed for now, let's check that it works

set -e

echo "Repository: $GITHUB_REPOSITORY"
echo "Actor: $GITHUB_ACTOR"

echo "Installing requirements..."

if [[ -f "requirements.txt" ]]; then
    # Ensure commitizen + reqs may have custom commitizen plugins
    pip install -r requirements.txt commitizen
else
    pip install commitizen
fi

echo "Runnung cz..."
if ! $INPUT_DRY_RUN; then
    cz bump --changelog
else
    cz bump --changelog --dry-run
fi

echo "Done."