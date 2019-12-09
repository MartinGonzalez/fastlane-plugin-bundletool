describe Fastlane::Actions::BundletoolAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The bundletool plugin is working!")

      Fastlane::Actions::BundletoolAction.run(nil)
    end
  end
end
