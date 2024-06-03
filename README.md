# Bundletool for Fastlane

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-bundletool) ![Gem Version](https://badge.fury.io/rb/fastlane-plugin-bundletool.svg) ![](https://ruby-gem-downloads-badge.herokuapp.com/fastlane-plugin-bundletool) [![YourActionName Actions Status](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/workflows/Release/badge.svg)](https://github.com/MartinGonzalez/fastlane-plugin-bundletool/actions) ![Gem Total Downloads](https://img.shields.io/gem/dtv/fastlane-plugin-bundletool)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-bundletool`, add it to your project by running:

```bash
fastlane add_plugin bundletool
```

or in your Pluginfile under fastlane folder write the following line and run `bundle install`.

```
gem 'fastlane-plugin-bundletool'
```

## About bundletool

**bundletool** is the underlying tool that Gradle, Android Studio, and Google Play use to build an Android App Bundle or convert an app bundle into the various APKs that are deployed to devices. bundletool is also available to you as a command line tool, so you can recreate, inspect, and verify Google Play’s server-side build of your app’s APKs.

https://developer.android.com/studio/command-line/bundletool

The motivation of this plugin is to extract an universal `.apk` file from an [.aab](https://fileinfo.com/extension/aab) file. Since we cannot distribute aab files, it's great that we can extract from the very same binary a file that we can distribute internally.

## Usage

In your Fastfile you need to use `bundletool` action. After you build the `.aab` file you can run the following code.

```ruby
bundletool(
  ks_path: keystore_path,
  ks_password: keystore_password,
  ks_key_alias: keystore_alias,
  ks_key_alias_password: keystore_alias_password,
  bundletool_version: '1.10.0', # For searching a specific version of bundletool visit https://github.com/google/bundletool/releases
  aab_path: aab_path,
  apk_output_path: apk_output_path,
  verbose: true,
  cache_path: cache_path
)
```

This will output the universal `.apk` in the output path you set.

## Options

| Key                   | Description                                             | Env Var(s)                      | Default |
|-----------------------|---------------------------------------------------------|---------------------------------|---------|
| ks_path               | Path to .jks file                                       | FL_BUNDLETOOL_KEYSTORE_FILE     |         |
| ks_password           | .jks password                                           | FL_BUNDLETOOL_KEYSTORE_PASSWORD |         |
| ks_key_alias          | Alias for jks                                           | FL_BUNDLETOOL_KEY_ALIAS         |         |
| ks_key_alias_password | Alias password for .jks                                 | FL_BUNDLETOOL_KEY_PASSWORD      |         |
| bundletool_version    | Version of bundletool to use, by default 0.11.0 will    | FL_BUNDLETOOL_VERSION           | 0.11.0  |
|                       | be used                                                 |                                 |         |
| download_url          | Url to download bundletool from, should point to a jar  | FL_BUNDLETOOL_DOWNLOAD_URL      |         |
|                       | file                                                    |                                 |         |
| aab_path              | Path where the aab file is                              | FL_BUNDLETOOL_AAB_PATH          |         |
| apk_output_path       | Path where the apk file is going to be placed           | FL_BUNDLETOOL_APK_OUTPUT_PATH   | .       |
| verbose               | Show every messages of the action                       | FL_BUNDLETOOL_VERBOSE           | false   |
| cache_path            | Cache downloaded bundletool binary into the cache path  | FL_BUNDLETOOL_CACHE_PATH        |         |
|-----------------------|---------------------------------------------------------|---------------------------------|---------|

## Use case

Here you can find a post I did explaining why I have to create this action.

https://medium.com/@gonzalez.martin90/bundletool-with-fastlane-8f8862ab16e0

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
