# commitizen-action

Commitizen github action to bump and create changelog

## Usage

1. In your repository create a `.cz.toml` file (you can run `cz init` to create it)
2. Create a `.github/workflows/bumpversion.yaml` with the Sample Workflow

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
      - name: Create bump and changelog
        uses: commitizen-tools/commitizen-action@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Variables

| Name           | Description                                                                           | Default     |
| -------------- | ------------------------------------------------------------------------------------- | ----------- |
| `github_token` | Token for the repo. Can be passed in using `${{ secrets.GITHUB_TOKEN }}` **required** | -           |
| `dry_run`      | Run without creating commit, output to stdout                                         | false       |
| `repository`   | Repository name to push. Default or empty value represents current github repository  | current one |
| `branch`       | Destination branch to push changes                                                    | `master`    |

<!--           | `changelog`                                                                                                  | Create changelog when bumping the version | true | -->

## Troubleshooting

### Other actions are not triggered when the tag is pushed

This problem occurs because `secrets.GITHUB_TOKEN` does not trigger other
actions [by design][by_design].

To solve it you must use a personal access token in the checkout and the commitizen steps.

Follow the instructions in [commitizen's documentation][cz-docs-ga]

[by_design]: https://docs.github.com/en/free-pro-team@latest/actions/reference/events-that-trigger-workflows#example-using-multiple-events-with-activity-types-or-configuration
[cz-docs-ga]: https://commitizen-tools.github.io/commitizen/tutorials/github_actions/
