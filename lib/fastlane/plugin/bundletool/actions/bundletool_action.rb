# frozen_string_literal: true

require 'fastlane/action'
require_relative '../helper/bundletool_helper'

module Fastlane
  module Actions
    class BundletoolAction < Action
      def self.run(params)
        print_params(params)
        @project_root = Dir.pwd
        @bundletool_temp_path = "#{@project_root}/bundletool_temp"
        @verbose = params[:verbose]
        keystore_info = {}
        unless params[:ks_path].nil?
          keystore_info[:keystore_path] = params[:ks_path]
          keystore_info[:keystore_password] = params[:ks_password]
          keystore_info[:alias] = params[:ks_key_alias]
          keystore_info[:alias_password] = params[:ks_key_alias_password]
        end

        bundletool_version = params[:bundletool_version]
        aab_path = params[:aab_path]
        output_path = params[:apk_output_path] || '.'

        return unless validate_aab!(aab_path)

        return unless download_bundletool(bundletool_version)

        extract_universal_apk_from(aab_path, output_path, keystore_info)
      end

      def self.validate_aab!(aab_path)
        puts_message('Checking if .aab file exists...')
        unless File.file?(aab_path)
          puts_error!(".aab file at #{aab_path} does not exist")
          return false
        end
        puts_success('Checking if .aab file exists')
      end

      def self.download_bundletool(version)
        puts_message("Downloading bundletool (#{version}) from https://github.com/google/bundletool/releases/download/#{version}/bundletool-all-#{version}.jar...")
        Dir.mkdir "#{@project_root}/bundletool_temp"        
        Kernel.open("https://github.com/google/bundletool/releases/download/#{version}/bundletool-all-#{version}.jar") do |bundletool|
          File.open("#{@bundletool_temp_path}/bundletool.jar", 'wb') do |file|
            file.write(bundletool.read)
          end
        end
        puts_success('Downloading bundletool')
      rescue StandardError => e
        clean_temp!
        puts_error!("Something went wrong when downloading bundletool version #{version}. \nError message\n #{e.message}")        
        false
      end

      def self.extract_universal_apk_from(aab_path, apk_output_path, keystore_info)
        aab_absolute_path = Pathname.new(File.expand_path(aab_path)).to_s
        apk_output_absolute_path = Pathname.new(File.expand_path(apk_output_path)).to_s
        output_path = run_bundletool!(aab_absolute_path, keystore_info)
        prepare_apk!(output_path, apk_output_absolute_path)
      rescue StandardError => e
        puts_error!("Bundletool could not extract universal apk from aab at #{aab_absolute_path}. \nError message\n #{e.message}")
      ensure
        clean_temp!
      end

      def self.run_bundletool!(aab_path, keystore_info)
        puts_message("Extracting apk from #{aab_path}...")
        output_path = "#{@bundletool_temp_path}/output.apks"
        keystore_params = ''

        unless keystore_info.empty?
          keystore_params = "--ks=\"#{keystore_info[:keystore_path]}\" --ks-pass=pass:#{keystore_info[:keystore_password]} --ks-key-alias=#{keystore_info[:alias]} --key-pass=pass:#{keystore_info[:alias_password]}"
        end

        cmd = "java -jar #{@bundletool_temp_path}/bundletool.jar build-apks --bundle=\"#{aab_path}\" --output=\"#{output_path}\" --mode=universal #{keystore_params}"

        Open3.popen3(cmd) do |_, _, stderr, wait_thr|
          exit_status = wait_thr.value
          raise stderr.read unless exit_status.success?
        end
        puts_success("Extracting apk from #{aab_path}")
        output_path
      end

      def self.prepare_apk!(output_path, target_path)
        puts_message("Preparing apk to #{target_path}...")
        if File.file?(target_path)
          puts_important("Apk at path #{target_path} exists. Replacing it.")
        end
        target_dir_name = File.dirname(target_path)
        unless Dir.exist?(target_dir_name)
          puts_important("Creating path #{target_dir_name} since does not exist")
          FileUtils.mkdir_p target_dir_name
        end
        cmd = "mv \"#{output_path}\" \"#{@bundletool_temp_path}/output.zip\" &&
        unzip \"#{@bundletool_temp_path}/output.zip\" -d \"#{@bundletool_temp_path}\" &&
        mv \"#{@bundletool_temp_path}/universal.apk\" \"#{target_path}\""
        Open3.popen3(cmd) do |_, _, stderr, wait_thr|
          exit_status = wait_thr.value
          raise stderr.read unless exit_status.success?
        end
        puts_success("Preparing apk to #{target_path}")
      end

      def self.clean_temp!
        cmd = "rm -rf #{@project_root}/bundletool_temp"
        Open3.popen3(cmd) do |_, _, stderr, wait_thr|
          exit_status = wait_thr.value
          raise stderr.read unless exit_status.success?
        end
      end

      def self.puts_message(message)
        UI.message message if @verbose
      end

      def self.puts_success(message)
        if @verbose
          UI.success "#{message} #{Fastlane::Helper::Emojis.green_checkmark}"
        end
      end

      def self.puts_important(message)
        if @verbose
          UI.important "#{message} #{Fastlane::Helper::Emojis.warning}"
        end
      end

      def self.puts_error!(message)
        p message
        UI.user_error! message
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ks_path,
                                       description: 'Path to .jks file',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ks_password,
                                       description: '.jks password',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ks_key_alias,
                                       description: 'Alias for jks',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ks_key_alias_password,
                                       description: 'Alias password for .jks',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :bundletool_version,
                                       description: 'Version of bundletool to use, by default 0.11.0 will be used',
                                       is_string: true,
                                       default_value: '0.11.0'),
          FastlaneCore::ConfigItem.new(key: :aab_path,
                                       description: 'Path where the aab file is',
                                       is_string: true,
                                       optional: false,
                                       verify_block: proc do |value|
                                                       unless value && !value.empty?
                                                         UI.user_error!('You must set aab_path.')
                                                       end
                                                     end),
          FastlaneCore::ConfigItem.new(key: :apk_output_path,
                                       description: 'Path where the apk file is going to be placed',
                                       is_string: true,
                                       optional: true,
                                       default_value: '.'),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: 'Show every messages of the action',
                                       is_string: false,
                                       type: Boolean,
                                       optional: true,
                                       default_value: false)

        ]
      end

      def self.print_params(options)
        table_title = "Params for bundletool #{Fastlane::Bundletool::VERSION}"
        FastlaneCore::PrintTable.print_values(config: options,
                                              mask_keys: %i[ks_password ks_key_alias_password],
                                              title: table_title)
      end

      def self.description
        'Extracts an universal apk from an .aab file'
      end

      def self.authors
        ['Martin Gonzalez']
      end

      def self.details
        'Using the google oficial bundletool to extract an universal apk from .aab file to distribute it'
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
