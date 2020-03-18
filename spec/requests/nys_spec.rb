describe 'NYS requests' do
  let(:user) { create_importer }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  context 'as a basic user' do
    let(:user) { create_really_basic_user }

    describe 'match_donations' do
      before do
        post '/nys/match_donations', params: { payload: { disclosure_ids: [1, 2, 3], donor_id: 1 } }
      end

      denies_access
    end

    describe 'unmatch donations' do
      before { post '/nys/unmatch_donations', params: { payload: { ny_match_ids: [1, 2, 3] } } }

      denies_access
    end

    describe 'potential contributions' do
      before { get '/nys/potential_contributions', params: { entity: 123 } }

      denies_access
    end

    describe 'contributions' do
      before { get '/nys/contributions', params: { entity: 123 } }

      denies_access
    end
  end

  describe 'match_donations' do
    let(:donor) { create(:entity_person).tap { |e| e.update_column(:updated_at, 1.year.ago) } }
    let(:disclosures) { Array.new(2) { create(:ny_disclosure) } }
    let(:match_donations) do
      proc do
        post '/nys/match_donations', params: { payload: { disclosure_ids: disclosures.map(&:id), donor_id: donor.id } }
      end
    end

    specify { expect(&match_donations).to change(NyMatch, :count).by(2) }
    specify { expect(&match_donations).to change { donor.reload.updated_at } }

    specify do
      expect(&match_donations).to change { donor.reload.last_user_id }.to(user.id)
    end

    describe 'response' do
      subject { response }

      before { match_donations.call }

      it { is_expected.to have_http_status(:accepted) }
    end
  end

  describe 'unmatch_donations' do
    let(:donor) { create(:entity_person) }
    let!(:disclosures) { Array.new(2) { create(:ny_disclosure) } }
    let!(:matches) { disclosures.map { |d| NyMatch.match(d.id, donor.id) } }
    let(:unmatch_donations) do
      proc do
        post '/nys/unmatch_donations', params: { payload: { ny_match_ids: matches.map(&:id) } }
      end
    end

    specify { expect(&unmatch_donations).to change(NyMatch, :count).by(-2) }

    describe 'response' do
      subject { response }

      before { unmatch_donations.call }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'creating NyFilerEntity' do
    subject { response }

    let(:entity) { create(:entity_org) }
    let(:ny_filer) { create(:ny_filer) }

    let(:entity_id) { entity.id }
    let(:id) { ny_filer.id }

    let(:request) do
      -> do
        post '/nys/ny_filer_entity',
             params: { 'entity_id' => entity_id, 'id' => id }
      end
    end

    context 'with valid request' do
      it 'creates a new NyFilerEntity' do
        expect(&request).to change(NyFilerEntity, :count).by(1)
      end

      it 'responds with success' do
        request.call
        expect(response).to have_http_status(:created)
      end
    end

    describe 'invalid requests' do
      context 'with nonexistent ny filer id' do
        before { request.call }

        let(:id) { 1_000_000 }

        it { is_expected.to have_http_status(:not_found) }
      end

      context 'with nonexistent entity' do
        before { request.call }

        let(:entity_id) { 1_000_000 }

        it { is_expected.to have_http_status(:not_found) }
      end

      context 'Ny filer is matched already' do
        before do
          NyFilerEntity.create!(entity_id: create(:entity_org).id, ny_filer: ny_filer, filer_id: ny_filer.id)
          request.call
        end

        it { is_expected.to have_http_status(:bad_request) }
      end
    end
  end
end
