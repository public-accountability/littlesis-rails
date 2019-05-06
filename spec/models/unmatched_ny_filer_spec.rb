describe UnmatchedNyFiler do
  it { is_expected.to have_db_column(:ny_filer_id) }
  it { is_expected.to have_db_column(:disclosure_count) }

  describe 'recreate!' do
    describe 'truncate' do
      specify do
        expect(UnmatchedNyFiler.count).to eq 0
        UnmatchedNyFiler.recreate!
        expect(UnmatchedNyFiler.count).to eq 0
        2.times { create(:ny_filer) }
        UnmatchedNyFiler.recreate!
        expect(UnmatchedNyFiler.count).to eq 2
      end
    end

    describe 'inserting data' do
      let(:ny_filers) { Array.new(3) { create(:ny_filer) } }

      # creates:
      #    - 3 ny filers
      #    - 1 ny_filer_entity
      #    - 3 ny_disclosures

      before do
        NyFilerEntity.create!(ny_filer_id: ny_filers[0].id, entity: create(:entity_person), filer_id: ny_filers[0].filer_id)
        create(:ny_disclosure_without_id, filer_id: ny_filers[1].filer_id)
        2.times { create(:ny_disclosure_without_id, filer_id: ny_filers[2].filer_id) }
        UnmatchedNyFiler.recreate!
      end

      specify do
        expect(UnmatchedNyFiler.count).to eq 2
        expect(UnmatchedNyFiler.find_by(ny_filer_id: ny_filers[1]).disclosure_count).to eq 1
        expect(UnmatchedNyFiler.find_by(ny_filer_id: ny_filers[2]).disclosure_count).to eq 2
      end
    end
  end
end
