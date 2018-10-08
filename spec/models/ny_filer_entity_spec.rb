require 'rails_helper'

describe NyFilerEntity, type: :model do
  it { is_expected.to belong_to(:ny_filer) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to validate_presence_of(:ny_filer_id) }
  it { is_expected.to validate_presence_of(:entity_id) }
  it { is_expected.to validate_presence_of(:filer_id) }
  it { is_expected.to callback(:rematch_existing_matches).after(:create) }

  describe 'associations' do
    let(:elected) { create(:entity_person, name: 'Elected Representative') }
    let(:ny_filer) { create(:ny_filer, filer_id: 'A1') }
    let(:filer_entity) { NyFilerEntity.create!(entity: elected, ny_filer: ny_filer, filer_id: 'A1') }

    it 'belongs to entity' do
      expect(filer_entity.entity).to eql elected
      expect(elected.ny_filer_entities.length).to eq 1
      expect(elected.ny_filer_entities[0].id).to eq filer_entity.id
    end

    it 'belongs to ny_filer' do
      expect(filer_entity.ny_filer).to eql ny_filer
      expect(ny_filer.entities.length).to eq 1
      expect(ny_filer.ny_filer_entity.present?).to be true
      expect(ny_filer.entities[0].id).to eql elected.id
      expect(ny_filer.ny_filer_entity.id).to eql filer_entity.id
    end
  end

  describe 'rematch_existing_matches' do
    it 'calls rematch on NyMatch for models' do
      elected = create(:elected)
      donor = create(:entity_person)
      ny_filer = create(:ny_filer, filer_id: 'A2')
      NyFilerEntity.create!(entity: elected, ny_filer: ny_filer, filer_id: 'A2')
      ny_disclosure = create(:ny_disclosure, ny_filer: ny_filer)
      NyMatch.create(ny_disclosure: ny_disclosure, donor_id: donor.id)
      expect(NyMatch.last.recip_id).to be nil
      expect { NyFilerEntity.last.rematch_existing_matches_without_delay }
        .to change { Relationship.count }.by(1)
      expect(NyMatch.last.recip_id).to eql elected.id
    end
  end

  describe 'updating unmatched_ny_filer table' do
    let!(:elected) { create(:entity_person) }
    let!(:donor) { create(:entity_person) }
    let!(:ny_filer) { create(:ny_filer) }

    let(:create_ny_filer_entity) do
      -> { NyFilerEntity.create!(entity: elected, ny_filer: ny_filer, filer_id: ny_filer.filer_id) }
    end

    before { UnmatchedNyFiler.recreate! } 

    context 'after creating' do
      it 'removes row from table', :run_delayed_jobs do
        expect(UnmatchedNyFiler.count).to eq 1
        with_delayed_job { create_ny_filer_entity.call }
        expect(UnmatchedNyFiler.count).to eq 0
      end
    end

    context 'after destroy' do
      before do
        create(:ny_disclosure_without_id, ny_filer: ny_filer, filer_id: ny_filer.filer_id)
      end

      it 'adds row to table' do
        expect(UnmatchedNyFiler.count).to eq 1
        with_delayed_job { create_ny_filer_entity.call }
        expect(UnmatchedNyFiler.count).to eq 0
        with_delayed_job { NyFilerEntity.last.destroy! }
        expect(UnmatchedNyFiler.count).to eq 1
        expect(UnmatchedNyFiler.last.ny_filer_id).to eq ny_filer.id
        expect(UnmatchedNyFiler.last.disclosure_count).to eq 1
      end
    end
  end
end
