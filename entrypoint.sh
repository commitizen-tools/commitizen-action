#!/bin/bash

if [ $INPUT_DRY_RUN ]; then INPUT_DRY_RUN='--dry-run'; else INPUT_DRY_RUN=''; fi
if [ $INPUT_CHANGELOG ]; then INPUT_CHANGELOG='--changelog'; else INPUT_CHANGELOG=''; fi
if [ $INPUT_PRERELEASE ]; then INPUT_PRERELEASE="--prerelease $INPUT_PRERELEASE"; else INPUT_PRERELEASE=''; fi
if [ "$INPUT_COMMIT" == 'false' ]; then INPUT_COMMIT='--files-only'; else INPUT_COMMIT=''; fi
if [ "$INPUT_COMMITIZEN_VERSION" == 'latest' ]; then INPUT_COMMITIZEN_VERSION="commitizen"; else INPUT_COMMITIZEN_VERSION="commitizen==$INPUT_COMMITIZEN_VERSION"; fi
if [ -n "$INPUT_NO_RAISE" ]; then INPUT_NO_RAISE="--no-raise $INPUT_NO_RAISE"; else INPUT_NO_RAISE=''; fi

CURRENT_BRANCH="$(git branch --show-current)"
INPUT_BRANCH=${INPUT_BRANCH:-$CURRENT_BRANCH}
INPUT_EXTRA_REQUIREMENTS=${INPUT_EXTRA_REQUIREMENTS:-''}
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}
# : "${INPUT_CHANGELOG:=true}" ignored for now, let's check that it works

set -e

[ -z "${INPUT_GITHUB_TOKEN}" ] && {
  echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".'
  exit 1
}

echo "Repository: $REPOSITORY"
echo "Actor: $GITHUB_ACTOR"

echo "Installing requirements..."
pip install "$INPUT_COMMITIZEN_VERSION" $INPUT_EXTRA_REQUIREMENTS
echo "Commitizen version:"
cz version

echo "Configuring git user and email..."
git config --local user.name "$INPUT_GIT_NAME"
git config --local user.email "$INPUT_GIT_EMAIL"
echo "Git name: $(git config --get user.name)"
echo "Git email: $(git config --get user.email)"

echo "Running cz: $INPUT_DRY_RUN $INPUT_COMMIT $INPUT_CHANGELOG $INPUT_PRERELEASE"

if [ $INPUT_CHANGELOG_INCREMENT_FILENAME ]; then
  cz $INPUT_NO_RAISE bump --yes --changelog-to-stdout $INPUT_COMMIT $INPUT_DRY_RUN $INPUT_CHANGELOG $INPUT_PRERELEASE >$INPUT_CHANGELOG_INCREMENT_FILENAME
else
  cz $INPUT_NO_RAISE bump --yes $INPUT_DRY_RUN $INPUT_COMMIT $INPUT_CHANGELOG $INPUT_PRERELEASE
fi

REV=$(cz version --project)
export REV

echo "REVISION=$REV" >>$GITHUB_ENV

echo "::set-output name=version::$REV"

if [ "$INPUT_PUSH" == "true" ]; then
  echo "Pushing to branch..."
  remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"
  git pull ${remote_repo} ${INPUT_BRANCH}
  git push "${remote_repo}" HEAD:${INPUT_BRANCH} --tags
else
  echo "Not pushing"
fi
echo "Done."
