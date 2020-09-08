describe ListDeletionRequest, type: :model do
  let(:user) { create(:user) }
  let(:list) { create(:list) }

  it 'has a valid factory' do
    create(:list_deletion_request, user: user, type: 'ListDeletionRequest', list: list)
  end

  describe '#approve!' do
    let(:req) { create(:list_deletion_request, user: user, type: 'ListDeletionRequest', list: list) }

    it 'soft deletes the list' do
      expect { req.approve! }.to change(list, :is_deleted).from(false).to(true)
    end
  end

  describe 'validations' do
    context 'without a list' do
      let(:req) { create(:list_deletion_request, user: user, type: 'ListDeletionRequest') }

      it 'raises a validation error' do
        expect { req }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: List can't be blank")
      end
    end

    context 'without a user' do
      let(:req) { create(:list_deletion_request, type: 'ListDeletionRequest', list: list) }

      it 'raises a validation error' do
        expect { req }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: User can't be blank")
      end
    end

    context 'without justification' do
      let(:req) do
        create(:list_deletion_request, user: user, justification: nil, type: 'ListDeletionRequest', list: list)
      end

      it 'raises a validation error' do
        expect { req }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Justification can't be blank")
      end
    end

    context 'without a status' do
      let(:req) { create(:list_deletion_request, user: user, type: 'ListDeletionRequest', list: list) }

      it 'has a default status of pending' do
        expect(req.status).to eq 'pending'
      end

      it 'raises a validation error' do
        req.status = nil
        expect(req.valid?).to be false
      end
    end
  end
end
