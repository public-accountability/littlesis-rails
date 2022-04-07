describe 'Relationships Requests' do
  let(:user) { create_editor }
  let(:person) { create(:entity_person, :with_person_name) }
  let(:org) { create(:entity_org, :with_org_name) }

  before { login_as(user, :scope => :user) }

  after { logout(:user) }

  describe 'Creating Relationships' do
    let(:params) do
      {
        relationship: {
          entity1_id: person.id,
          entity2_id: org.id,
          category_id: 1,
          is_current: 'YES',
          description1: 'Director'
        },
        reference: attributes_for(:document)
      }
    end

    let(:request) { -> { post relationships_path, params: params } }

    context 'valid position relationship' do
      specify do
        expect(&request).to change(Relationship, :count).by(1)
      end

      specify do
        expect(&request).to change(Reference, :count).by(3)
      end

      specify do
        expect(&request).to change { person.reload.last_user_id }.to(user.id)
      end

      specify do
        expect(&request).to change { org.reload.last_user_id }.to(user.id)
      end

      it 'responds with json containing the relationship id' do
        request.call
        expect(json).to eq('relationship_id' => Relationship.last.id)
      end

      context 'is board membership' do
        before do
          params[:relationship][:position_attributes] = { is_board: 'true' }
        end

        specify do
          expect(&request).to change(Relationship, :count).by(1)
        end

        it 'corrects updates "is_board" on position' do
          expect(&request).to change { Position.count }.by(1)
          expect(Position.last.is_board).to be true
        end
      end

      context 'is not a board member' do
        before do
          params[:relationship][:position_attributes] = { is_board: 'no' }
        end

        specify do
          expect(&request).to change(Relationship, :count).by(1)
        end

        it 'corrects updates "is_board" on position' do
          expect(&request).to change { Position.count }.by(1)
          expect(Position.last.is_board).to eql false
        end
      end
    end

    context 'with invalid url' do
      before { params[:reference][:url] = 'I AM A BAD URL' }

      specify do
        expect(&request).not_to change(Relationship, :count)
      end

      it 'rends json of errors' do
        request.call
        expect(response).to have_http_status :bad_request
        expect(response.body).to include 'is not a valid url'
      end
    end

    context 'with amount field but no currency' do
      before { params[:relationship][:amount] = '$25,000' }

      it 'adds USD amount to relationship' do
        expect(&request).to change(Relationship, :count).by(1)
        expect(Relationship.last.amount).to eq 25_000
        expect(Relationship.last.currency).to eq 'usd'
      end
    end

    context 'with amount and currency' do
      before { params[:relationship].merge!(amount: '13000', currency: 'eur') }

      it 'adds currency and amount to relationship' do
        expect(&request).to change(Relationship, :count).by(1)
        expect(Relationship.last.amount).to eq 13_000
        expect(Relationship.last.currency).to eq 'eur'
      end
    end

    context 'with currency but no amount' do
      before { params[:relationship].merge!(amount: nil, currency: 'aud') }

      it 'raises validation error' do
        expect(&request).not_to change(Relationship, :count)
        expect(response).to have_http_status :bad_request
        expect(response.body).to include 'entered without an amount'
      end
    end
  end

  describe 'Updating relationships' do
    let(:notes) { Faker::Lorem.sentence }

    describe 'Position Relationship' do
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
    end # Position Relationship

    describe 'Transaction Relationship' do
      let(:entity1) { create(:entity_org, :with_org_name) }
      let(:entity2) { create(:entity_org, :with_org_name) }

      let(:transaction_relationship) do
        Relationship.create!(category_id: Relationship::TRANSACTION_CATEGORY,
                             entity: entity1,
                             related: entity2,
                             description1: 'Contractor',
                             description2: 'Client')
      end

      let(:base_params) do
        {
          reference: { just_cleaning_up: 1, url: nil, name: nil },
          relationship: {
            description1: 'Contractor',
            description2: 'Client',
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
  end # end updating relationships

  describe 'deleting relationship' do
    with_versioning do
      let!(:relationship) do
        PaperTrail.request(whodunnit: user.id.to_s) do
          create(:generic_relationship, entity: create(:entity_person), related: create(:entity_person))
        end
      end

      context 'when requesting as the editor who created' do
        it 'deletes relationship and redirects to dashboard' do
          delete relationship_path(relationship)
          expect(relationship.reload.is_deleted).to be true
          expect(response.status).to eq 302
          expect(response.location).to include '/home/dashboard'
        end

        it 'cannot delete when it is more than an week ago'  do
          relationship.update_columns(created_at: 1.month.ago)
          delete relationship_path(relationship)
          expect(relationship.reload.is_deleted).to be false
          expect(response.status).to eq 403
        end
      end
    end
  end
end
