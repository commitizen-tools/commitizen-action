#!/bin/bash

: "${INPUT_DRY_RUN:=false}"
INPUT_BRANCH=${INPUT_BRANCH:-master}
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}
# : "${INPUT_CHANGELOG:=true}" ignroed for now, let's check that it works

set -e

[ -z "${INPUT_GITHUB_TOKEN}" ] && {
    echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".';
    exit 1;
};

echo "Repository: $REPOSITORY"
echo "Actor: $GITHUB_ACTOR"

echo "Installing requirements..."
if [[ -f "requirements.txt" ]]; then
    # Ensure commitizen + reqs may have custom commitizen plugins
    pip install -r requirements.txt commitizen
else
    pip install commitizen
fi

echo "Configuring git user and email..."
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"

if ! $INPUT_DRY_RUN; then
    echo "Running cz..."
    cz bump --yes --changelog
else
    echo "Running dry run cz..."
    cz bump --yes --changelog --dry-run
fi

echo "Pushing to branch..."
remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"
git push "${remote_repo}" HEAD:${INPUT_BRANCH} --follow-tags --tags;

echo "Done."
