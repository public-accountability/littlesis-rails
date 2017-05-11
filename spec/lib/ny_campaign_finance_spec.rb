require 'rails_helper'
require Rails.root.join('lib', 'task-helpers', 'nys_campaign_finance.rb')

describe 'NYSCampaignFinance' do
  describe 'insert_new_disclosures' do
    it 'loops through batches' do
      expect(NYSCampaignFinance).to receive(:get_staging_batch).with(0).and_return(['data'])
      expect(NYSCampaignFinance).to receive(:get_staging_batch).with(2000).and_return([])
      expect(NYSCampaignFinance).to receive(:import_disclosure_batch).twice.with(kind_of(Array), kind_of(Hash), false)
      NYSCampaignFinance.insert_new_disclosures
    end
  end

  without_transactional_fixtures do
    describe '#import_disclosure_data' do
      before do
        NYSCampaignFinance.drop_staging_table
        NYSCampaignFinance.create_staging_table
      end

      it 'creates 2 records from test file' do
        NYSCampaignFinance.import_disclosure_data(Rails.root.join('spec', 'testdata', 'disclosures_test.csv'))
        expect(NYSCampaignFinance.row_count).to eq 2
      end

      it 'adds 1 new disclosure, skipping duplicate' do
        create(:ny_disclosure_for_import_test)
        NYSCampaignFinance.import_disclosure_data(Rails.root.join('spec', 'testdata', 'disclosures_test.csv'))
        expect { NYSCampaignFinance.insert_new_disclosures }.to change { NyDisclosure.count }.by(1)
        expect { NYSCampaignFinance.insert_new_disclosures }.not_to change { NyDisclosure.count }
      end
    end
  end
end
