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
      - name: Create bump and changelog
        uses: commitizen-tools/commitizen-action@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Variables

| Name           | Description                                                                                                  | Default     |
| -------------- | ------------------------------------------------------------------------------------------------------------ | ----------- |
| `github_token` | Token for the repo. Can be passed in using \$\{{ secrets.GITHUB_TOKEN }} **required**                        | -           |
| `dry_run`      | Run without creating commit, output to stdout                                                                | false       |
| `repository`   | Repository name to push. Default or empty value represents current github repository (\${GITHUB_REPOSITORY}) | current one |
| `branch`       | Destination branch to push changes                                                                           | `master`    |

<!--           | `changelog`                                                                                                  | Create changelog when bumping the version | true | -->

If you use `secrets.GITHUB_TOKEN` other actions won't be triggered.
To solve that you will need a personal access token.
Follow the instructions of [github tutorial](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token#creating-a-token) in order
to create one

