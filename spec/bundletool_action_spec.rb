# frozen_string_literal: true

describe 'BundletoolAction.run should' do
  it 'throws error when bundletool fails' do
    aab_path = 'path/example.aab'
    aab_absolute_path = Pathname.new(File.expand_path(aab_path)).to_s
    bundletool_url = 'https://github.com/google/bundletool/releases/download/0.11.0/bundletool-all-0.11.0.jar'
    error = 'error'
    allow(File).to receive(:file?).with(aab_path).and_return(true)
    allow(Kernel).to receive(:open).with(bundletool_url).and_return('somebody')
    allow(Fastlane::Actions::BundletoolAction).to receive(:run_bundletool!).and_raise(StandardError.new(error))
    expect(FastlaneCore::UI).to receive(:user_error!).with("Bundletool could not extract universal apk from aab at #{aab_absolute_path}. \nError message\n #{error}")
    Fastlane::Actions::BundletoolAction.run(verbose: true,
                                            bundletool_version: '0.11.0',
                                            aab_path: aab_path)
  end
  it 'throws error when downloading bundletool fails' do
    aab_path = 'path/example.aab'
    allow(File).to receive(:file?).with(aab_path).and_return(true)
    bundletool_url = 'https://github.com/google/bundletool/releases/download/0.11.0/bundletool-all-0.11.0.jar'
    allow(Kernel).to receive(:open).with(bundletool_url).and_raise(StandardError.new('error'))

    expect(FastlaneCore::UI).to receive(:user_error!).with("Something went wrong when downloading bundletool version 0.11.0. \nError message\n error")

    Fastlane::Actions::BundletoolAction.run(verbose: true,
                                            bundletool_version: '0.11.0',
                                            aab_path: aab_path,
                                            apk_output_path: '/resources/example.apk')
  end
  it 'throws .aab file does not exist UI.user_error! when providing invalid .aab file path' do
    invalid_path = 'some_invalid_dir/example.aab'
    expect(FastlaneCore::UI).to receive(:user_error!).with('.aab file at some_invalid_dir/example.aab does not exist')
    Fastlane::Actions::BundletoolAction.run(verbose: true,
                                            bundletool_version: '0.11.0',
                                            aab_path: invalid_path,
                                            apk_output_path: '/resources/example.apk')
  end
end
