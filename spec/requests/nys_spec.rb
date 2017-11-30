require 'rails_helper'

describe 'NYS requests' do
  let(:user) { create_importer }
  before { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  context 'as a basic user' do
    let(:user) { create_really_basic_user }

    context 'match_donations' do
      before { post '/nys/match_donations', { payload: { disclosure_ids: [1,2,3], donor_id: 1 } }}
      denies_access
    end

    context 'unmatch donations' do
      before { post '/nys/unmatch_donations', { payload: { ny_match_ids: [1, 2, 3] } } }
      denies_access
    end

    context 'potential contributions' do
      before { get '/nys/potential_contributions', entity: 123 }
      denies_access
    end

    context 'contributions' do
      before { get '/nys/contributions', entity: 123 }
      denies_access
    end
  end

  describe 'match_donations' do
    let(:donor) { create(:entity_person).tap { |e| e.update_column(:updated_at, 1.year.ago) } }
    let(:disclosures) { Array.new(2) { create(:ny_disclosure)} }
    let(:match_donations) do
      proc do
        post '/nys/match_donations', { payload: { disclosure_ids: disclosures.map(&:id), donor_id: donor.id } }
      end
    end

    specify { expect(&match_donations).to change { NyMatch.count }.by(2) }
    specify { expect(&match_donations).to change { donor.reload.updated_at } }

    specify do
      expect(&match_donations).to change { donor.reload.last_user_id }.to(user.sf_guard_user_id)
    end

    context 'response' do
      before { match_donations.call }
      subject { response }
      it { is_expected.to have_http_status(:accepted) }
    end
  end

  describe 'unmatch_donations' do
    let(:donor) { create(:entity_person) }
    let!(:disclosures) { Array.new(2) { create(:ny_disclosure) } }
    let!(:matches) { disclosures.map { |d| NyMatch.match(d.id, donor.id) } }
    let(:unmatch_donations) do
      proc do
        post '/nys/unmatch_donations', { payload: { ny_match_ids: matches.map(&:id) } }
      end
    end

    specify { expect(&unmatch_donations).to change { NyMatch.count }.by(-2) }

    context 'response' do
      before { unmatch_donations.call }
      subject { response }
      it { is_expected.to have_http_status(200) }
    end
  end
end
