# require Rails.root.join('lib', 'nys_campaign_finance.rb')

# xdescribe 'NYSCampaignFinance' do
#   describe 'insert_new_disclosures' do
#     it 'loops through batches' do
#       expect(NYSCampaignFinance).to receive(:row_count).twice.and_return(2)
#       expect(NYSCampaignFinance).to receive(:staging_disclosures_to_add).and_return([1,2])
#       expect(NyDisclosure).to receive(:find_by_sql)
#                                .with("SELECT * FROM #{NYSCampaignFinance::STAGING_TABLE_NAME} where id = 1 LIMIT 1")
#                                .and_return( [ build(:ny_disclosure) ] )
#       expect(NyDisclosure).to receive(:find_by_sql)
#                                .with("SELECT * FROM #{NYSCampaignFinance::STAGING_TABLE_NAME} where id = 2 LIMIT 1")
#                                .and_return( [ build(:ny_disclosure, report_id: 'B') ] )

#       NYSCampaignFinance.insert_new_disclosures
#     end
#   end

#   without_transactional_fixtures do
#     describe '#import_disclosure_data' do
#       before do
#         NYSCampaignFinance.drop_staging_table
#         NYSCampaignFinance.create_staging_table
#       end

#       it 'creates 2 records from test file' do
#         NYSCampaignFinance.import_disclosure_data(Rails.root.join('spec', 'testdata', 'disclosures_test.csv'))
#         expect(NYSCampaignFinance.row_count).to eq 2
#       end

#       it 'adds 1 new disclosure, skipping duplicate' do
#         create(:ny_disclosure_for_import_test)
#         NYSCampaignFinance.import_disclosure_data(Rails.root.join('spec', 'testdata', 'disclosures_test.csv'))
#         expect { NYSCampaignFinance.insert_new_disclosures }.to change { NyDisclosure.count }.by(1)
#         expect { NYSCampaignFinance.insert_new_disclosures }.not_to change { NyDisclosure.count }
#       end
#     end
#   end
# end
