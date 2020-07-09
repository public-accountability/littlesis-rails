describe SpamDetector do
  describe 'bug_report?' do
    specify do
      expect(SpamDetector.bug_report?('page' => 'https://littlesis.org/bug_report')).to be false
    end

    specify do
      expect(Rails.logger).to receive(:info).with(/spam@bot\.com/)
      expect(SpamDetector.bug_report?('page' => 'https://example.com','email'=> 'spam@bot.com')).to be true
    end
  end
end
