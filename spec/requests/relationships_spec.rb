require 'rails_helper'

describe 'Relationships Requests' do
  let(:user) { create_really_basic_user }
  before(:each) { login_as(user, :scope => :user) }
  after(:each) { logout(:user) }

  describe 'Updating relationships' do
    let(:notes) { Faker::Lorem.sentence }
    let(:person) { create(:entity_person, :with_person_name) }
    let(:org) { create(:entity_org, :with_org_name) }

    describe 'Position Relationshi' do
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

      context 'updating relationship fields' do
        it 'redirects to relationship page' do
          patch_request.call
          redirects_to_path relationship_path(position_relationship)
        end

        it 'updates relationship fields and position fields' do
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
          expect(position_relationship.entity1_id).to eql person.id
        end
      end

      context 'submitting an invalid date' do
        let(:params) { base_params.deep_merge(relationship: { start_date: 'BAD DATE' }) }
        before { patch_request.call }
        renders_the_edit_page

        it 'does not change the relationship' do
          expect(position_relationship.reload.start_date).to be nil
          expect(position_relationship.reload.notes).to be nil
        end
      end
    end # Positiong Relationship

    describe 'Transaction Relationship' do
      let(:entity1) { create(:entity_org, :with_org_name) }
      let(:entity2) { create(:entity_org, :with_org_name) }

      let(:transaction_relationship) do
        Relationship.create!(category_id: Relationship::TRANSACTION_CATEGORY,
                             entity: entity1,
                             related: entity2,
                             description1: "Contractor",
                             description2: "Client")
      end

      let(:base_params) do
        {
          reference: { just_cleaning_up: 1, url: nil, name: nil },
          relationship: {
            description1: "Contractor",
            description2: "Client",
            start_date: '',
            end_date: '',
            is_current: '',
            notes: '',
            trans_attributes: { is_lobbying: 'true' }
          }
        }
      end
      let(:params) { base_params }
      let(:patch_request) { proc { patch relationship_path(transaction_relationship), params: params } }

      def self.updates_transaction_fields
        it 'upates relationship and transaction fields' do
          expect(transaction_relationship.trans.is_lobbying).to be_nil
          patch_request.call
          transaction_relationship.reload
          redirects_to_path relationship_path(transaction_relationship)
          expect(transaction_relationship.trans.is_lobbying).to be true
        end
      end

      context 'updating without reversing' do
        let(:params) { base_params.deep_merge(reverse_direction: 'false') }

        updates_transaction_fields

        it 'does not reverse the relationship' do
          patch_request.call
          transaction_relationship.reload
          expect(transaction_relationship.trans.is_lobbying).to be true
          expect(transaction_relationship.entity1_id).to eql entity1.id
          expect(transaction_relationship.entity2_id).to eql entity2.id
        end
      end

      context 'updating AND reversing' do
        let(:params) { base_params.deep_merge(reverse_direction: 'true') }

        updates_transaction_fields

        it 'reverses the relationship' do
          patch_request.call
          transaction_relationship.reload
          expect(transaction_relationship.trans.is_lobbying).to be true
          expect(transaction_relationship.entity1_id).to eql entity2.id
          expect(transaction_relationship.entity2_id).to eql entity1.id
        end
      end
    end # end updating and reversing
  end
end
