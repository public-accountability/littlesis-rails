require 'rails_helper'
require Rails.root.join('lib', 'task-helpers', 'nys_campaign_finance.rb')

describe 'NYSCampaignFinance' do
  without_transactional_fixtures do
    describe '#import_disclosure_data' do
      before do
        NYSCampaignFinance.drop_staging_table
        NYSCampaignFinance.create_staging_table
      end

      it 'creates 2 records from test file' do
        NYSCampaignFinance.import_disclosure_data(Rails.root.join('spec', 'testdata', 'ALL_REPORTS_test.txt'))
        expect(NYSCampaignFinance.row_count).to eq 2
      end

      it 'adds 1 new disclosure, skipping duplicate' do
        create(:ny_disclosure_for_import_test)
        NYSCampaignFinance.import_disclosure_data(Rails.root.join('spec', 'testdata', 'ALL_REPORTS_test.txt'))
        expect { NYSCampaignFinance.insert_new_disclosures }.to change { NyDisclosure.count }.by(1)
      end
    end
  end
end
