require 'rails_helper'

describe 'Relationships requests' do
  let(:user) { create_really_basic_user }
  before(:each) { login_as(user, :scope => :user) }
  after(:each) { logout(:user) }

  describe 'updating relationships' do
    let(:notes) { Faker::Lorem.sentence }
    let(:person) { create(:entity_person, :with_person_name) }
    let(:org) { create(:entity_org, :with_org_name) }

    let(:position_relationship) do
      Relationship
        .create!(category_id: 1, entity: person, related: org, description1: 'Lobbyist')
        .tap { |r| r.position.update_columns(is_executive: true) }
    end

    let(:base_params) do
      {
        reference: { just_cleaning_up: 1, url: nil, name: nil },
        relationship: {
          description1: 'Lobbyist',
          start_date: '2009',
          end_date: nil,
          is_current: nil,
          notes: notes,
          position_attributes: {
            is_board: 'true',
            is_executive: 'true',
            is_employee: nil,
            compensation: nil,
            id: position_relationship.position.id
          }
        }
      }
    end
    let(:params) { base_params }
    let(:patch_request) { proc { patch relationship_path(position_relationship), params: params } }

    context 'updating the fields of a relationship' do
      it 'redirects to relationship page' do
        patch_request.call
        redirects_to_path relationship_path(position_relationship)
      end

      it 'updates relationship fields' do
        expect(position_relationship.start_date).to be_nil
        expect(position_relationship.notes).to be_nil
        expect(position_relationship.position.is_board).to be_nil
        expect(position_relationship.position.is_executive).to be true
        patch_request.call
        position_relationship.reload
        expect(position_relationship.start_date).to eql '2009-00-00'
        expect(position_relationship.position.is_board).to be true
        expect(position_relationship.position.is_executive).to be true
        expect(position_relationship.notes).to eql notes
      end
    end

    context 'invalid date' do
      let(:params) { base_params.deep_merge(relationship: { start_date: 'BAD DATE' }) }
      before { patch_request.call }
      renders_the_edit_page

      it 'does not change the relationship' do
        expect(position_relationship.reload.start_date).to be nil
        expect(position_relationship.reload.notes).to be nil
      end
    end
  end
end
