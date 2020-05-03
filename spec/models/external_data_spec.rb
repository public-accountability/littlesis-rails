describe ExternalData, type: :model do
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:dataset_id).of_type(:string) }
  it { is_expected.to have_db_column(:data).of_type(:text) }

  describe ExternalData::IapdOwner do
    specify 'person owner' do
      owner = ExternalData::IapdOwner.new([
                                            { 'owner_type' => 'I' }
                                          ])
      expect(owner.send(:instance_variable_get, :@primary_ext)).to eq 'Person'
      expect(owner.person?).to be true
    end
  end
end
