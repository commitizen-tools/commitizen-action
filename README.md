# commitizen-action

Commitizen github action to bump and create changelog

## Usage

1. In your local repo remember to create a `.cz.toml` file (run `cz init` to create it)
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
    runs-on: ubuntu-latest
    name: 'Bump version and create changelog with commitizen'
    steps:
    - name: Check out
      uses: actions/checkout@v2
    - name: Create bump and changelog
      uses: Woile/commitizen-action@master
      with:
        dry_run: false
    - name: Push changes back to master
      uses: ad-m/github-push-action@master
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}

```

## Variables

| Name        | Description                                   | Default |
| ----------- | --------------------------------------------- | ------- |
| `dry_run`   | Run without creating commit, output to stdout | false   |
| `changelog` | Create changelog when bumping the version     | true    |

## Contributing

Whenever we want to release a new version, we have to mark it as breaking change.
The `.cz.toml` configuration is using `$major` to format the tag, this means that
it's the only kind of release allowed, so, mark as breaking change.
