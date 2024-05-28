# frozen_string_literal: true

require 'fastlane/action'
require 'shellwords'
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
        download_url = params[:download_url]
        aab_path = params[:aab_path]
        output_path = params[:apk_output_path] || '.'
        cache_path = params[:cache_path]

        return unless validate_aab!(aab_path)

        if(cache_path.nil?)
          installation_path = @bundletool_temp_path
        else
          installation_path = Pathname.new(File.expand_path(cache_path)).to_s          
        end

        unless(Dir.exist?(installation_path))
          Dir.mkdir(installation_path)
        end

        unless(Dir.exist?(@bundletool_temp_path))
          Dir.mkdir(@bundletool_temp_path)
        end

        unless download_url.nil?
          bundletool_filename = "bundletool_#{id = Digest::SHA256.hexdigest(download_url)}.jar"
        else
          bundletool_filename = "bundletool_#{bundletool_version}.jar"
        end

        return unless download_bundletool(bundletool_version, download_url, bundletool_filename, installation_path)

        extract_universal_apk_from(aab_path, output_path, keystore_info, bundletool_filename, installation_path)
      end

      def self.validate_aab!(aab_path)
        puts_message('Checking if .aab file exists...')
        unless File.file?(aab_path)
          puts_error!(".aab file at #{aab_path} does not exist")
          return false
        end
        puts_success('Checking if .aab file exists')
        return true
      end

      def self.download_bundletool(version, download_url, bundletool_filename, cache_path)              
        unless download_url.nil?          
          download_and_write_bundletool(download_url, bundletool_filename, cache_path)
        else
          bundletool_url = "https://github.com/google/bundletool/releases/download/#{version}/bundletool-all-#{version}.jar"
          download_and_write_bundletool(bundletool_url, bundletool_filename, cache_path)
        end        
        return true
      rescue OpenURI::HTTPError => e
        clean_temp!
        puts_error!("Something went wrong when downloading bundletool version #{version}" + ". \nError message\n #{e.message}")
        return false
      end      

      def self.extract_universal_apk_from(aab_path, apk_output_path, keystore_info, bundletool_filename, installation_path)
        aab_absolute_path = Pathname.new(File.expand_path(aab_path)).to_s
        apk_output_absolute_path = Pathname.new(File.expand_path(apk_output_path)).to_s
        output_path = run_bundletool!(aab_absolute_path, keystore_info, bundletool_filename, installation_path)
        prepare_apk!(output_path, apk_output_absolute_path)
      rescue StandardError => e
        puts_error!("Bundletool could not extract universal apk from aab at #{aab_absolute_path}. \nError message\n #{e.message}")
      ensure
        clean_temp!
      end

      def self.run_bundletool!(aab_path, keystore_info, bundletool_filename, installation_path)
        puts_message("Extracting apk from #{aab_path}...")
        output_path = "#{@bundletool_temp_path}/output.apks"
        keystore_params = ''

        unless keystore_info.empty?
          key_alias_password = Shellwords.shellescape("pass:#{keystore_info[:alias_password]}")
          key_store_password = Shellwords.shellescape("pass:#{keystore_info[:keystore_password]}")
          key_alias = Shellwords.shellescape(keystore_info[:alias])
          keystore_params = "--ks=#{keystore_info[:keystore_path]} --ks-pass=#{key_store_password} --ks-key-alias=#{key_alias} --key-pass=#{key_alias_password}"
        end

        cmd = "java -jar #{installation_path}/#{bundletool_filename} build-apks --bundle=\"#{aab_path}\" --output=\"#{output_path}\" --mode=universal #{keystore_params}"

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
                                       env_name: 'FL_BUNDLETOOL_KEYSTORE_FILE',
                                       description: 'Path to .jks file',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ks_password,
                                       env_name: 'FL_BUNDLETOOL_KEYSTORE_PASSWORD',
                                       description: '.jks password',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ks_key_alias,
                                       env_name: 'FL_BUNDLETOOL_KEY_ALIAS',
                                       description: 'Alias for jks',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ks_key_alias_password,
                                       env_name: 'FL_BUNDLETOOL_KEY_PASSWORD',
                                       description: 'Alias password for .jks',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :bundletool_version,
                                       env_name: 'FL_BUNDLETOOL_VERSION',
                                       description: 'Version of bundletool to use, by default 0.11.0 will be used',
                                       is_string: true,
                                       default_value: '0.11.0'),
          FastlaneCore::ConfigItem.new(key: :download_url,
                                       env_name: 'FL_BUNDLETOOL_DOWNLOAD_URL',
                                       description: 'Url to download bundletool from, should point to a jar file',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :aab_path,
                                       env_name: 'FL_BUNDLETOOL_AAB_PATH',
                                       description: 'Path where the aab file is',
                                       is_string: true,
                                       optional: false,
                                       verify_block: proc do |value|
                                         unless value && !value.empty?
                                           UI.user_error!('You must set aab_path.')
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :apk_output_path,
                                       env_name: 'FL_BUNDLETOOL_APK_OUTPUT_PATH',
                                       description: 'Path where the apk file is going to be placed',
                                       is_string: true,
                                       optional: true,
                                       default_value: '.'),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: 'FL_BUNDLETOOL_VERBOSE',
                                       description: 'Show every messages of the action',
                                       is_string: false,
                                       type: Boolean,
                                       optional: true,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :cache_path,
                                       env_name: 'FL_BUNDLETOOL_CACHE_PATH',
                                       description: 'Cache downloaded bundletool binary into the cache path specified',
                                       is_string: true,
                                       optional: true)
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

      private

      def self.download_and_write_bundletool(download_url, bundletool_filename, installation_path)
        if(File.exist?"#{installation_path}/#{bundletool_filename}")
          puts_message("Using binary cached at #{installation_path}/#{bundletool_filename}")
          return
        end

        puts_message("Downloading bundletool from #{download_url}")

        URI.open(download_url) do |bundletool|
          File.open("#{installation_path}/#{bundletool_filename}", 'wb') do |file|
            file.write(bundletool.read)
          end
        end

        puts_success('Downloaded bundletool')
      end
    end
  end
end
