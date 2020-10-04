#!/bin/bash

if [ $INPUT_DRY_RUN ]; then INPUT_DRY_RUN='--dry-run'; else INPUT_DRY_RUN=''; fi
if [ $INPUT_CHANGELOG ]; then INPUT_CHANGELOG='--changelog'; else INPUT_CHANGELOG=''; fi
if [ $PRERELEASE ]; then PRERELEASE="--prerelease $PRERELEASE"; else PRERELEASE=''; fi
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


echo "Running cz: $INPUT_DRY_RUN $INPUT_CHANGELOG $PRERELEASE"
cz bump --yes $INPUT_DRY_RUN $INPUT_CHANGELOG $PRERELEASE


echo "Pushing to branch..."
remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"
git push "${remote_repo}" HEAD:${INPUT_BRANCH} --follow-tags --tags;

echo "Done."
