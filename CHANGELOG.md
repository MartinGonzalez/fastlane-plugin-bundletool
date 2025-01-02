# [1.1.0](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/compare/v1.0.12...v1.1.0) (2025-01-02)


### Features

* make --mode=universal configurable ([#26](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/issues/26)) ([7f3fc3e](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/commit/7f3fc3edf20d65b70c3cf2c20a5ee5fa5f45016a))

## [1.0.12](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/compare/v1.0.11...v1.0.12) (2024-10-07)


### Bug Fixes

* use single quotes in keystore path to handle paths containing spaces ([#24](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/issues/24)) ([c69bed6](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/commit/c69bed60a6adb0ee69b3ce5d01ba5b1cd459ab4b))

## [1.0.11](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/compare/v1.0.10...v1.0.11) (2024-07-23)


### Bug Fixes

* multiline string cmd for prepare_apk ([#23](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/issues/23)) ([ceb9fe1](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/commit/ceb9fe1d104eaf2d3dc97cb14a2be811240e9f6d))

## [1.0.10] - 2024-05-28
- Handle special characters by @christianEconify in #17

## [1.0.9] - 2023-04-27
- Added `env_name` to input parameters to be able to read variables from dotenv. Thanks to @txuslee

## [1.0.8] - 2022-03-08
- Added `cache_path` option to be able to cache bundletool binary. If `version` is used it will save the binary as bundletool_VERSION.jar and if you use `download_url` it will save it as bundletool_SHA_BASE_ON_URL.jar

## [1.0.7] - 2022-02-16
- Fix error when `verbose` is set to false.

## [1.0.6] - 2022-03-29
- Adding a `download_url` option to point to a specific bundletool url. Thanks to @alienwizard

## [1.0.5] - 2022-02-11
- Use single quotes for bundletool parameters to avoid special characters conflict.

## [1.0.4] - 2021-08-12

### Fixed
- Kernel.open replaced with URI.open to avoid ruby versions conflicts. Thanks to @TofiBashers

## [1.0.3] - 2020-10-13

### Fixed
Escape keystore_info params passed to bundletool. Thanks to @pradel pull request

## [1.0.2] - 2020-05-26

### Fixed
- Paths with spaces. Thanks to @ricky-scopely

## [1.0.1] - 2020-02-21

### Fixed
- bundle_tool creating recursive directories. Thanks to @jam-cmesquita
- rubocop offenses.

## [1.0.0] - 2019-12-08

### Added
- bundle_tool action
