# Bundletool for Fastlane

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-bundletool)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-bundletool`, add it to your project by running:

```bash
fastlane add_plugin bundletool
```

or in your Pluginfile under fastlane folder write the following line and run `bundle install`.

```
gem 'fastlane-plugin-bundletool', '1.0.2'
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
  bundletool_version: '0.11.0',
  aab_path: aab_path,
  apk_output_path: apk_output_path,
  verbose: true
)
```

This will output the universal `.apk` in the output path you set.

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
