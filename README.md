# commitizen-action

Add [commitizen][cz] incredibly fast into your project!

## Features

- Allow prerelease
- Super easy to setup
- Automatically bump version
- Automatically create changelog
- Update any file in your repo with the new version

Are you using [conventional commits][cc] and [semver][semver]?

Then you are ready to use this github action! The only thing you'll need is the
`.cz.toml` file in your project.

## Usage

1. In your repository create a `.cz.toml` file (you can run `cz init` to create it)
2. Create a `.github/workflows/bumpversion.yaml` with the Sample Workflow

### Minimal configuration

Your `.cz.toml` (or `pyproject.toml` if you are using python) should look like
this.

```toml
[tool.commitizen]
version = "0.1.0"  # This should be your current semver version
```

For more information visit [commitizen's configuration page][cz-conf]

## Sample Workflow

```yaml
name: Bump version

on:
  push:
    branches:
      - master

jobs:
  bump_version:
    if: "!startsWith(github.event.head_commit.message, 'bump:')"
    runs-on: ubuntu-latest
    name: "Bump version and create changelog with commitizen"
    steps:
      - name: Check out
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
          token: "${{ secrets.GITHUB_TOKEN }}"
      - id: cz
        name: Create bump and changelog
        uses: commitizen-tools/commitizen-action@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
      - name: Print Version
        run: echo "Bumped to version ${{ steps.cz.outputs.version }}"
```

## Variables

| Name                           | Description                                                                                                                                                                                                                       | Default                                                         |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `github_token`                 | Token for the repo. Can be passed in using `${{ secrets.GITHUB_TOKEN }}`. Required if `push: true`                                                                                                                                | -                                                               |
| `dry_run`                      | Run without creating commit, output to stdout                                                                                                                                                                                     | false                                                           |
| `repository`                   | Repository name to push. Default or empty value represents current github repository                                                                                                                                              | current one                                                     |
| `branch`                       | Destination branch to push changes                                                                                                                                                                                                | Same as the one executing the action by default                 |
| `prerelease`                   | Set as prerelease {alpha,beta,rc} choose type of prerelease                                                                                                                                                                       | -                                                               |
| `extra_requirements`           | Custom requirements, if your project uses a custom rule or plugins, you can specify them separated by a space. E.g: `'commitizen-emoji conventional-JIRA'`                                                                        | -                                                               |
| `changelog_increment_filename` | Filename to store the incremented generated changelog. This is different to changelog as it only contains the changes for the just generated version. Example: `body.md`                                                          | -                                                               |
| `git_redirect_stderr`          | Redirect git output to stderr. Useful if you do not want git output in your changelog                                                                                                                                             | `false`                                                         |
| `git_name`                     | Name used to configure git (for git operations)                                                                                                                                                                                   | `github-actions[bot]`                                           |
| `git_email`                    | Email address used to configure git (for git operations)                                                                                                                                                                          | `github-actions[bot]@users.noreply.github.com`                  |
| `push`                         | Define if the changes should be pushed to the branch.                                                                                                                                                                             | true                                                            |
| `merge`                        | Define if the changes should be pushed even on the pull_request event, immediately merging the pull request.                                                                                                                      | false                                                           |
| `commit`                       | Define if the changes should be committed to the branch.                                                                                                                                                                          | true                                                            |
| `commitizen_version`           | Specify the version to be used by commitizen. Eg: `2.21.                                                                                                                                                                          | latest                                                          |
| `changelog`                    | Create changelog when bumping the version                                                                                                                                                                                         | true                                                            |
| `no_raise`                     | Don't raise the given comma-delimited exit codes (e.g., no_raise: '20,21'). Use with caution! Open an issue in [commitizen](https://github.com/commitizen-tools/commitizen/issues) if you need help thinking about your workflow. | [21](https://commitizen-tools.github.io/commitizen/exit_codes/) |
| `increment`                    | Manually specify the desired increment {MAJOR,MINOR, PATCH}                                                                                                                                                                       | -                                                               |
| `check_consistency`            | Check consistency among versions defined in commitizen configuration and version_files                                                                                                                                            | `false`                                                         |
| `gpg_sign`                     | If true, use GPG to sign commits and tags (for git operations). Requires separate setup of GPG key and passphrase in GitHub Actions (e.g. with the action `crazy-max/ghaction-import-gpg`)                                        | `false`                                                         |
| `debug`                        | Prints debug output to GitHub Actions stdout                                                                                                                                                                                      | `false`                                                         |

## Outputs

| Name      | Description     |
| --------- | --------------- |
| `version` | The new version |

The new version is also available as an environment variable under `REVISION` or you can access using `${{ steps.cz.outputs.version }}`

## Using SSH with deploy keys

1. Create a [deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys) (which is the SSH **public key**)
2. Add the **private key** as a [Secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) in your repository, e.g: `COMMIT_KEY`
3. Set up your action

```yaml
name: Bump version

on:
  push:
    branches:
      - main

jobs:
  bump-version:
    if: "!startsWith(github.event.head_commit.message, 'bump:')"
    runs-on: ubuntu-latest
    name: "Bump version and create changelog with commitizen"
    steps:
      - name: Check out
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
          ssh-key: "${{ secrets.COMMIT_KEY }}"
      - name: Create bump and changelog
        uses: commitizen-tools/commitizen-action@master
        with:
          push: false
      - name: Push using ssh
        run: |
          git push origin main --tags
```

## Creating a Github release

```yaml
name: Bump version

on:
  push:
    branches:
      - main

jobs:
  bump-version:
    if: "!startsWith(github.event.head_commit.message, 'bump:')"
    runs-on: ubuntu-latest
    name: "Bump version and create changelog with commitizen"
    steps:
      - name: Check out
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
          token: "${{ secrets.PERSONAL_ACCESS_TOKEN }}"
      - name: Create bump and changelog
        uses: commitizen-tools/commitizen-action@master
        with:
          github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          changelog_increment_filename: body.md
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: "body.md"
          tag_name: ${{ env.REVISION }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Troubleshooting

### Other actions are not triggered when the tag is pushed

This problem occurs because `secrets.GITHUB_TOKEN` do not trigger other
actions [by design][by_design].

To solve it, you must use a personal access token in the checkout and the commitizen steps.

Follow the instructions in [commitizen's documentation][cz-docs-ga].

## I'm not using conventional commits, I'm using my own set of rules on commits

If your rules can be parsed, then you can build your own commitizen rules,
create a new commitizen python package, or you can describe it on the `toml` config itself.

[Read more about customization][cz-custom]

[by_design]: https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#example-using-multiple-events-with-activity-types-or-configuration
[cz-docs-ga]: https://commitizen-tools.github.io/commitizen/tutorials/github_actions/
[cz]: https://commitizen-tools.github.io/commitizen/
[cc]: https://www.conventionalcommits.org/
[semver]: https://semver.org/
[cz-conf]: https://commitizen-tools.github.io/commitizen/config/
[cz-custom]: https://commitizen-tools.github.io/commitizen/customization/
