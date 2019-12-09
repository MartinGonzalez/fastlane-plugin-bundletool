describe Fastlane::Actions::BundletoolAction do
  describe '#run' do
    it 'throws UI.user_error! when providing invalid .aab file path' do
      # invalid_path = "some_invalid_dir/exmaple.aab"
      # expect(Fastlane::Actions::BundletoolAction).to receive(:puts_error!).with(".aab file at #{invalid_path} does not exist")

      # Fastlane::Actions::BundletoolAction.run(verbose: true,
      #   bundletool_version: '0.11.0',
      #   aab_path: invalid_path,
      #   apk_output_path: '/resources/example.apk'
      # )
    end
  end
end
