describe SpamDetector do
  describe 'bug_report?' do
    specify do
      expect(SpamDetector.bug_report?('page' => 'https://littlesis.org/bug_report')).to be false
    end

    specify do
      expect(Rails.logger).to receive(:info).with(/spam@bot\.com/)
      expect(SpamDetector.bug_report?('page' => 'https://example.com', 'email'=> 'spam@bot.com')).to be true
    end
  end

  describe 'mostly_cyrillic?' do
    specify do
      expect(SpamDetector.mostly_cyrillic?('Если жизнь тебя обманет')).to be true
    end

    specify do
      expect(SpamDetector.mostly_cyrillic?('foo bar')).to be false
    end

    specify do
      expect(SpamDetector.mostly_cyrillic?("it's okay to have use some кириллица")).to be false
    end
  end
end
