# rubocop:disable Rails/Date, RSpec/MessageSpies

require 'importers'

describe NYSDisclosureImporter do
  before do
    stub_const('NYSDisclosureImporter::LOCAL_PATH',
               Rails.root.join('spec/testdata/nys_campaign_finance_all_reports.zip').to_s)
  end

  describe 'when downloading should happen' do
    specify 'file does not exist' do
      expect(Utility).to receive(:file_is_empty_or_nonexistent)
                           .once
                           .with(Rails.root.join('spec/testdata/nys_campaign_finance_all_reports.zip').to_s)
                           .and_return(true)

      expect(NYSDisclosureImporter.send(:should_download?)).to be true
    end

    specify 'file exists and was edited yesterday' do
      expect(Utility).to receive(:file_is_empty_or_nonexistent).once.and_return(false)
      expect(File).to receive(:ctime).once.and_return(Time.zone.yesterday.to_time)
      expect(NYSDisclosureImporter.send(:should_download?)).to be true
    end

    specify 'file exists and was edited today' do
      expect(Utility).to receive(:file_is_empty_or_nonexistent).once.and_return(false)
      expect(File).to receive(:ctime).once.and_return(Time.zone.today.to_time)
      expect(NYSDisclosureImporter.send(:should_download?)).to be false
    end
  end

  it 'creates 10 ExternalData' do
    expect { NYSDisclosureImporter.run }.to change(ExternalData, :count).by(10)
  end

  it 'creates 10 ExternalRelationship' do
    expect { NYSDisclosureImporter.run }.to change(ExternalRelationship, :count).by(10)
  end
end

# rubocop:enable Rails/Date, RSpec/MessageSpies
