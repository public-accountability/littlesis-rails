describe ElectedRepresentative do
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to have_db_column(:fec_ids) }

  describe 'fec_ids' do
    let(:entity) do
      create(:entity_person).tap do |e|
        e.add_extension('ElectedRepresentative')
      end
    end

    it 'starts as blank array' do
      expect(entity.elected_representative.fec_ids).to eql []
    end

    it 'can be appended to' do
      expect(entity.elected_representative.fec_ids).to eql []
      entity.elected_representative.fec_ids << 'H1234'
      expect(entity.elected_representative.fec_ids.length).to eql 1
      entity.elected_representative.fec_ids << 'S5678'
      expect(entity.elected_representative.fec_ids.length).to eql 2
      entity.elected_representative.save!
      expect(entity.elected_representative.fec_ids).to eql %w[H1234 S5678]
    end
  end
end
