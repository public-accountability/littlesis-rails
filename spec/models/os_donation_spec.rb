describe OsDonation, type: :model do

  describe 'validations' do
    subject { build(:os_donation) }

    it { is_expected.to validate_uniqueness_of(:fec_cycle_id).case_insensitive }
  end

  describe 'create_fec_cycle_id' do
    it 'creates id' do
      d = OsDonation.new(cycle: '2010', fectransid: '123')
      expect(d.fec_cycle_id).to be_nil
      d.create_fec_cycle_id
      expect(d.fec_cycle_id).to eql('2010_123')
    end
  end

  describe 'Reference Helper Methods' do
    let(:os_d) { OsDonation.new(microfilm: '123') }

    describe 'reference_name' do

      it 'returns the reference name using microfilm' do
        expect(os_d.reference_name).to eql "FEC Filing 123"
      end

      it 'returns the reference name when  microfilm is nil' do
        expect(OsDonation.new.reference_name).to eql "FEC Filing "
      end
    end

    describe 'reference_source' do

      it 'returns general search link if microfilm is nil' do
        expect(OsDonation.new.reference_source)
          .to eql 'http://www.fec.gov/finance/disclosure/advindsea.shtml'
      end

      it 'returns link to fec img' do
        expect(os_d.reference_source).to eql 'http://docquery.fec.gov/cgi-bin/fecimg/?123'
      end

    end
  end
end
