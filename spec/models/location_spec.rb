describe Location do
  it { is_expected.to have_db_column(:city).of_type(:text) }
  it { is_expected.to have_db_column(:country).of_type(:text) }
  it { is_expected.to have_db_column(:subregion).of_type(:text) }
  it { is_expected.to have_db_column(:region).of_type(:integer) }
  it { is_expected.to have_db_column(:lat).of_type(:decimal) }
  it { is_expected.to have_db_column(:lng).of_type(:decimal) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }

  it { is_expected.to belong_to(:entity).required }
  it { is_expected.to have_one(:address) }

  describe 'region' do
    specify do
      expect(Location.new(region: 2).region).to eq 'Asia'
    end
  end
end
