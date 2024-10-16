# Changelog

All notable changes to this project will be documented in this file.

# [2.1.0](https://github.com/tofuutils/pre-commit-opentofu/compare/v2.0.0...v2.1.0) (2024-10-16)


### Features

* spport .tofu files ([#6](https://github.com/tofuutils/pre-commit-opentofu/issues/6)) ([e059c58](https://github.com/tofuutils/pre-commit-opentofu/commit/e059c5859bceddf1ca018f55851f6940ad51f1c2))

# [2.0.0](https://github.com/tofuutils/pre-commit-opentofu/compare/v1.0.4...v2.0.0) (2024-09-25)


### Features

* **tofu:** add handling for missing tofu binary in Docker image  This commit introduces logic to gracefully handle the case when the tofu binary is not found in the Docker image, improving the overall user experience.  BREAKING CHANGE: The previous behavior of the application when the tofu binary was missing may have caused unexpected crashes. ([14fc63e](https://github.com/tofuutils/pre-commit-opentofu/commit/14fc63eb5b04e3ad1525d06e437b15935841775f))


### BREAKING CHANGES

* **tofu:** The previous behavior of the application when the tofu binary was missing may have caused unexpected crashes."

## [1.0.4](https://github.com/tofuutils/pre-commit-opentofu/compare/v1.0.3...v1.0.4) (2024-09-21)


### Bug Fixes

* docker image reference in README.md ([7b04f0c](https://github.com/tofuutils/pre-commit-opentofu/commit/7b04f0c24940f1642c8f599bfd0794dd46b0b274))
* docker image reference in README.md ([f9b71fe](https://github.com/tofuutils/pre-commit-opentofu/commit/f9b71fe08fedd4ceb23ced6fe2171edf24add290))
* dockerhub ([0fac591](https://github.com/tofuutils/pre-commit-opentofu/commit/0fac59197f2f2cb4bc417917e5adb6ac92a20b7a))
* entry for tofu_docs_replace ([f146463](https://github.com/tofuutils/pre-commit-opentofu/commit/f146463ac8effcfa441f3f6b21e811095f0da73c))

## [1.0.2](https://github.com/tofuutils/pre-commit-opentofu/compare/v1.0.1...v1.0.2) (2024-03-08)


### Bug Fixes

* remove obsolete terraform checks and awk file hack ([97cba7a](https://github.com/tofuutils/pre-commit-opentofu/commit/97cba7a646996c7cae3719f1b6241d47da5882d9))

## [1.0.1](https://github.com/tofuutils/pre-commit-opentofu/compare/v1.0.0...v1.0.1) (2024-03-07)


### Bug Fixes

* dockerfile ([65b197c](https://github.com/tofuutils/pre-commit-opentofu/commit/65b197c841dc10aa772c7fc2594a213a9158d2f4))

# [1.0.0](https://github.com/tofuutils/pre-commit-opentofu/compare/v1.0.0) (2023-12-21)


### Features

* TODO
