#!/usr/bin/env bash

set -e
set +o posix

if [[ -z $INPUT_GITHUB_TOKEN ]]; then
  echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".' >&2
  exit 1
fi

echo "Configuring Git username, email, and pull behavior..."
git config --local user.name "${INPUT_GIT_NAME}"
git config --local user.email "${INPUT_GIT_EMAIL}"
git config --local pull.rebase true
echo "Git name: $(git config --get user.name)"
echo "Git email: $(git config --get user.email)"

if [[ $INPUT_GPG_SIGN == 'true' ]]; then
  if [[ -z $INPUT_GPG_PRIVATE_KEY ]]; then
    echo 'Missing input "gpg_private_key".' >&2
    exit 2
  fi
  if [[ -z $INPUT_GPG_PASSPHRASE ]]; then
    echo 'Missing input "gpg_passphrase".' >&2
    exit 3
  fi

  echo "Configuring GPG agent..."
  if [ -f /usr/lib/systemd/user/gpg-agent.service ]; then
    mkdir ~/.gnupg
    cat <<EOT >> ~/.gnupg/gpg-agent.conf
    allow-preset-passphrase
    default-cache-ttl 60
    max-cache-ttl 50
EOT
    chmod 600 ~/.gnupg/*
    chmod 700 ~/.gnupg
    systemctl --user restart gpg-agentarent of 2cf68aa (fix(entrypoint.sh): replace `systemctl`)
  else
    gpg-agent --daemon --allow-preset-passphrase \
    --default-cache-ttl 60 --max-cache-ttl 60
  fi

  echo "Importing GPG key..."
  echo -n "${INPUT_GPG_PRIVATE_KEY}" | base64 --decode \
    | gpg --pinentry-mode loopback \
      --passphrase-file <(echo "${INPUT_GPG_PASSPHRASE}") \
      --import
  GPG_FINGERPRINT=$(gpg -K --with-fingerprint \
    | sed -n 4p | sed -e 's/ *//g')
  echo "${GPG_FINGERPRINT}:6:" | gpg --import-ownertrust

  echo "Setting GPG passphrase..."
  GPG_KEYGRIP=$(gpg --with-keygrip -K \
    | sed -n '/[S]/{n;p}' \
    | sed 's/Keygrip = //' \
    | sed 's/ *//g')
  GPG_PASSPHRASE_HEX=$(echo -n "${INPUT_GPG_PASSPHRASE}" \
    | od -A n -t x1 \
    | tr -d ' ' | tr -d '\n')
  echo "PRESET_PASSPHRASE $GPG_KEYGRIP -1 $GPG_PASSPHRASE_HEX" | gpg-connect-agent

  echo "Configuring Git for GPG..."

  export CI_SIGNINGKEY_UID=$( \
    gpg --list-signatures --with-colons \
    | grep 'sig' \
    | grep  "${INPUT_GIT_EMAIL}" \
    | head -n 1 \
    | cut -d':' -f5 \
  )
  git config --local commit.gpgsign true
  git config --local tag.gpgsign true
  git config --local user.signingkey "${CI_SIGNINGKEY_UID}"
  echo "Git sign commits?: $(git config --get commit.gpgsign)"
  echo "Git sign tags?: $(git config --get tag.gpgsign)"
fi

PIP_CMD=('pip' 'install')
if [[ $INPUT_COMMITIZEN_VERSION == 'latest' ]]; then
  PIP_CMD+=('commitizen')
else
  PIP_CMD+=("commitizen==${INPUT_COMMITIZEN_VERSION}")
fi
IFS=" " read -r -a INPUT_EXTRA_REQUIREMENTS <<<"$INPUT_EXTRA_REQUIREMENTS"
PIP_CMD+=("${INPUT_EXTRA_REQUIREMENTS[@]}")
echo "${PIP_CMD[@]}"
"${PIP_CMD[@]}"
echo "Commitizen version: $(cz version)"

PREV_REV="$(cz version --project)"

CZ_CMD=('cz')
if [[ $INPUT_DEBUG == 'true' ]]; then
  CZ_CMD+=('--debug')
fi
if [[ $INPUT_NO_RAISE ]]; then
  CZ_CMD+=('--no-raise' "$INPUT_NO_RAISE")
fi
CZ_CMD+=('bump' '--yes')
if [[ $INPUT_GPG_SIGN == 'true' ]]; then
  CZ_CMD+=('--gpg-sign')
fi
if [[ $INPUT_DRY_RUN == 'true' ]]; then
  CZ_CMD+=('--dry-run')
fi
if [[ $INPUT_CHANGELOG == 'true' ]]; then
  CZ_CMD+=('--changelog')
fi
if [[ $INPUT_PRERELEASE ]]; then
  CZ_CMD+=('--prerelease' "$INPUT_PRERELEASE")
fi
if [[ $INPUT_COMMIT == 'false' ]]; then
  CZ_CMD+=('--files-only')
fi
if [[ $INPUT_INCREMENT ]]; then
  CZ_CMD+=('--increment' "$INPUT_INCREMENT")
fi
if [[ $INPUT_CHECK_CONSISTENCY ]]; then
  CZ_CMD+=('--check-consistency')
fi
if [[ $INPUT_CHANGELOG_INCREMENT_FILENAME ]]; then
  CZ_CMD+=('--changelog-to-stdout')
  echo "${CZ_CMD[@]}" ">$INPUT_CHANGELOG_INCREMENT_FILENAME"
  "${CZ_CMD[@]}" >"$INPUT_CHANGELOG_INCREMENT_FILENAME"
else
  echo "${CZ_CMD[@]}"
  "${CZ_CMD[@]}"
fi

REV="$(cz version --project)"
if [[ $REV == "$PREV_REV" ]]; then
  INPUT_PUSH='false'
fi
echo "REVISION=${REV}" >>"$GITHUB_ENV"
echo "version=${REV}" >>"$GITHUB_OUTPUT"

CURRENT_BRANCH="$(git branch --show-current)"
INPUT_BRANCH="${INPUT_BRANCH:-$CURRENT_BRANCH}"
INPUT_REPOSITORY="${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}"

echo "Repository: ${INPUT_REPOSITORY}"
echo "Actor: ${GITHUB_ACTOR}"

if [[ $INPUT_PUSH == 'true' ]]; then
  if [[ $INPUT_MERGE != 'true' && $GITHUB_EVENT_NAME == 'pull_request' ]]; then
    echo "Refusing to push on pull_request event since that would merge the pull request." >&2
    echo "You probably want to run on push to your default branch instead." >&2
  else
    echo "Pushing to branch..."
    REMOTE_REPO="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${INPUT_REPOSITORY}.git"
    git pull "$REMOTE_REPO" "$INPUT_BRANCH"
    git push "$REMOTE_REPO" "HEAD:${INPUT_BRANCH}" --tags
  fi
else
  echo "Not pushing"
fi
echo "Done."
