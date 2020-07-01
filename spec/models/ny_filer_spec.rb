describe NyFiler, type: :model do
  subject { create(:ny_filer) }

  it { is_expected.to have_one(:ny_filer_entity) }
  it { is_expected.to have_many(:entities) }
  it { is_expected.to have_many(:ny_disclosures) }
  it { is_expected.to validate_presence_of(:filer_id) }
  it { is_expected.to validate_uniqueness_of(:filer_id).case_insensitive }

  describe '#office_description' do
    it 'translates numeric office code to text description' do
      filer = build(:ny_filer, office: 22)
      expect(filer.office_description).to eq 'Mayor'
    end

    it 'returns nils if code is missing from lookup hash' do
      filer = build(:ny_filer, office: 100)
      expect(filer.office_description).to be nil
    end
  end

  describe 'matched? / raise_if_matched!' do
    let(:entity) { create(:entity_org) }
    let(:ny_filer) { create(:ny_filer, filer_id: '123') }

    context 'with matched entity' do
      before { create(:ny_filer_entity, ny_filer_id: ny_filer.id, entity: entity) }

      it 'returns true if there is a filer_entity' do
        expect(ny_filer.is_matched?).to be true
      end

      it 'has alias "matched?"' do
        expect(ny_filer.matched?).to be true
      end

      it 'raise_if_matched! throws error' do
        expect { ny_filer.raise_if_matched! }
          .to raise_error(NyFiler::AlreadyMatchedError)
      end
    end

    context 'without a matched entity' do
      before { ny_filer }

      it 'returns false if there is no filer_entity' do
        expect(ny_filer.is_matched?).to be false
      end

      it 'raise_if_matched! does not throws error' do
        expect { ny_filer.raise_if_matched! }.not_to raise_error
      end
    end
  end

  describe 'unmatched' do
    let!(:matched_nyfiler) do
      create(:ny_filer).tap do |ny_filer|
        NyFilerEntity.create!(entity: create(:entity_org),
                              ny_filer: ny_filer,
                              filer_id: ny_filer.filer_id)
      end
    end

    let!(:unmatched_filers) do
      Array.new(2) { create(:ny_filer) }
    end

    it 'returns only unmatched filers' do
      expect(NyFiler.count).to eq 3
      expect(NyFiler.unmatched.count).to eq 2
    end
  end
end
