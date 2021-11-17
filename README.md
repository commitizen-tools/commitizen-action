# commitizen-action

Add [commitizen][cz] incredibly fast into your project!

## Features

- Allow prerelease
- Super easy to setup
- Automatically bump version
- Automatically create changelog
- Update any file in your repo with the new version

Are you using [conventional commits][cc] and [semver][semver]?

Then you are ready to use this github action, the only thing you'll need is the
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
        uses: actions/checkout@v2
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

| Name                           | Description                                                                                                                                                              | Default                                        |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------- |
| `github_token`                 | Token for the repo. Can be passed in using `${{ secrets.GITHUB_TOKEN }}` **required**                                                                                    | -                                              |
| `dry_run`                      | Run without creating commit, output to stdout                                                                                                                            | false                                          |
| `repository`                   | Repository name to push. Default or empty value represents current github repository                                                                                     | current one                                    |
| `branch`                       | Destination branch to push changes                                                                                                                                       | `master`                                       |
| `prerelease`                   | Set as prerelease {alpha,beta,rc} choose type of prerelease                                                                                                              | -                                              |
| `extra_requirements`           | Custom requirements, if your project uses a custom rule or plugins, you can specify them separated by a space. E.g: `'commitizen-emoji conventional-JIRA'`               | -                                              |
| `changelog_increment_filename` | Filename to store the incremented generated changelog. This is different to changelog as it only contains the changes for the just generated version. Example: `body.md` | -                                              |
| `git_name`                     | Name used to configure git (for git operations)                                                                                                                          | `github-actions[bot]`                          |
| `git_email`                    | Email address used to configure git (for git operations)                                                                                                                 | `github-actions[bot]@users.noreply.github.com` |
| `push`                         | Define if the changes should be pushed to the branch.                                                                                                                    | true                                           |
| `commit`                       | Define if the changes should be committed to the branch.                                                                                                                 | true                                           |
<!--           | `changelog`                                                                                                  | Create changelog when bumping the version | true | -->

## Outputs

| Name      | Description          |
| --------- | -------------------- |
| `version` | The new version      |

Additionally, the new version is also availble as an environment variable under `REVISION`.

## Troubleshooting

### Other actions are not triggered when the tag is pushed

This problem occurs because `secrets.GITHUB_TOKEN` does not trigger other
actions [by design][by_design].

To solve it you must use a personal access token in the checkout and the commitizen steps.

Follow the instructions in [commitizen's documentation][cz-docs-ga]

## I'm not using conventional commits, I'm using my own set of rules on commits

If your rules can be parsed then you can build your own commitizen rules, you can
create a new commitizen python package or you can describe it on the `toml` conf itself.

[Read more about customization][cz-custom]

[by_design]: https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#example-using-multiple-events-with-activity-types-or-configuration
[cz-docs-ga]: https://commitizen-tools.github.io/commitizen/tutorials/github_actions/
[cz]: https://commitizen-tools.github.io/commitizen/
[cc]: https://www.conventionalcommits.org/
[semver]: https://semver.org/
[cz-conf]: https://commitizen-tools.github.io/commitizen/config/
[cz-custom]: https://commitizen-tools.github.io/commitizen/customization/
