## 0.18.1 (2023-03-28)

### Fix

- Add support for GitHub Enterprise Server (#66)

## 0.18.0 (2023-03-03)

### BREAKING CHANGE

- Remove `use_ssh`. Documentation is in place to deploy using SSH keys

### Fix

- remove use_ssh flag (#65)

## 0.17.1 (2023-03-03)

### Fix

- add openssh to Dockerfile

## 0.17.0 (2023-03-03)

### Feat

- add support for SSH deploy keys (#64)

## 0.16.3 (2023-02-09)

### Fix

- missing `libffi-dev` in `Dockerfile` which breaks third party plugins (#60)

## 0.16.2 (2023-02-06)

### Fix

- change docker image version back to 3.8 (#59)

## 0.16.1 (2023-02-05)

### Fix

- add safe directory to git (#57)

## 0.16.0 (2023-01-07)

### Feat

- **entrypoing.sh**: add `gpg` sign
- **debug**: add option for debug output

### Fix

- check_consistency flag being ignored

## 0.15.1 (2022-10-18)

### Fix

- Port from set-output to environment files

## 0.15.0 (2022-10-04)

### Feat

- add `check-consistency` option

## 0.14.1 (2022-07-07)

### Fix

- Refuse to push on pull_request event
- Don't pull or push with nothing to push
- Print error message to stderr

## 0.14.0 (2022-07-05)

### Fix

- remove bad comma

### Feat

- add increment option

## 0.13.2 (2022-05-11)

### Fix

- Don't quote the > operator in entrypoint.sh
- Don't quote the > operator in entrypoint.sh
- Follow Bash best practices in entrypoint
- Configure git pull to rebase instead of merge
- Configure git pull to rebase instead of merge

### Refactor

- Remove unnecessary --follow-tags
- Get current Git branch more simply

## 0.13.1 (2022-05-10)

### Fix

- Correct default branch from master to current

## 0.13.0 (2022-05-04)

### Feat

- add no-raise option
- add no-raise option

## 0.12.0 (2022-02-24)

### Feat

- add commitizen version input
- add commitizen version input

### Refactor

- rename cz version variable

## 0.11.0 (2021-12-18)

### Feat

- detect default branch
- detect default branch

## 0.10.0 (2021-11-17)

### Feat

- add `commit` and `push` inputs

## 0.9.0 (2021-09-14)

### Feat

- add version output

## 0.8.0 (2021-08-30)

### Fix

- removed id from default git_email

### Feat

- support  custom git config

## 0.7.0 (2021-03-08)

### Feat

- add support for `--changelog-to-stdout`

### Fix

- use commitizen-tool action instead of Woile's

## 0.6.0 (2021-02-06)

### Feat

- add pull before pushing to avoid error with remote with new changes

## 0.5.0 (2020-12-02)

### Feat

- add extra_requirements parameters instead of reading the requirements.txt file

## 0.4.0 (2020-11-24)

### Feat

- add echo Commitizen version to better debug (#4)

## 0.3.0 (2020-10-05)

### Feat

- add prerelease option

## 0.2.1 (2020-10-04)

### Fix

- **entrypoint**: typo correction

## 0.2.0 (2020-08-13)

### Feat

- change tag format

## 0.1.0 (2020-08-13)

### Feat

- add parameters `github_token`, `repository` and `branch`
- introduce github action

### Fix

- **entrypoint**: add git user and email
- add 'yes' arg to bump
- remove tag format
