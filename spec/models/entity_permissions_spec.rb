describe Entity::Permissions do
  with_versioning do
    let(:user) { create_basic_user }

    before do
      PaperTrail.request(whodunnit: user.id.to_s) do
        @entity = create(:entity_person)
      end
    end

    describe 'the entity was recently' do
      it 'the creator can delete the entity but not merge' do
        expect(@entity.permissions_for(user).deleteable).to be true
        expect(@entity.permissions_for(user).mergeable).to be false
      end

      it 'other users cannot delete or merge the entity' do
        another_user = create_basic_user
        expect(@entity.permissions_for(another_user).deleteable).to be false
        expect(@entity.permissions_for(another_user).mergeable).to be false
      end
    end

    describe 'The entity was recently created but has more than 2 relationships' do
      before do
        @entity.update_columns(link_count: 10)
      end

      it 'the creator cannot delete the entity' do
        expect(@entity.permissions_for(user).deleteable).to be false
      end
    end

    describe 'the entity was created more than a week ago' do
      before do
        @entity.update_columns(created_at: 1.month.ago)
      end

      it 'the creator cannot delete the entity' do
        expect(@entity.permissions_for(user).deleteable).to be false
      end

      it 'an admin can delete and merge the entity' do
        admin_user = create_admin_user
        expect(@entity.permissions_for(admin_user).deleteable).to be true
        expect(@entity.permissions_for(admin_user).mergeable).to be true
      end
    end
  end
end
