require 'rails_helper'

describe 'User Permissions', type: :model do
  it 'user has permissions class' do
    user = create_basic_user
    expect(user.permissions).to be_a UserPermissions::Permissions
  end

  describe 'user.permissions.edit_list?' do
    it 'users can edit entities from lists they\'ve created' do
      user = create_contributor
      list_created_by_user = create(:list, creator_user_id: user.id)
      list_created_by_somone_else = create(:list, creator_user_id: user.id + 1)
      expect(user.permissions.edit_list?(list_created_by_user)).to be true
      expect(user.permissions.edit_list?(list_created_by_somone_else)).to be false
    end

    it 'users with lister permissions can edit any list' do
      lister = create_list_user
      contributor = create_contributor
      list = create(:list)
      expect(lister.permissions.edit_list?(list)).to be true
      expect(contributor.permissions.edit_list?(list)).to be false
    end

    it 'private lists can only be edited by the list owner' do
      lister = create_list_user
      contributor = create_contributor
      list = create(:list, creator_user_id: contributor.id, is_private: true)
      expect(lister.permissions.edit_list?(list)).to be false
      expect(contributor.permissions.edit_list?(list)).to be true
    end

    it 'admin lists can only be edited by admins' do
      lister = create_list_user
      admin = create_admin_user
      list = build(:list, is_admin: true)
      expect(lister.permissions.edit_list?(list)).to be false
      expect(admin.permissions.edit_list?(list)).to be true
    end
  end
  
end

describe UserPermissions::Permissions do
  describe 'initalize' do
    context 'basic user with contributor, editor, and lister permissions' do
      before(:all) do
        @user = create_basic_user
        @permission = UserPermissions::Permissions.new(@user)
      end

      it 'initializes with user' do
        expect(@permission.instance_variable_get('@user')).to eq @user
      end

      it 'initializes with sf_permissions' do
        expect(@permission.instance_variable_get('@sf_permissions')).to eq ['contributor', 'editor','lister']
      end

      it 'contributor? returns true' do
        expect(@permission.contributor?).to be true
      end

      it 'editor? returns true' do
        expect(@permission.editor?).to be true
      end

      it 'lister? returns true' do
        expect(@permission.lister?).to be true
      end

      it 'admin? returns false' do
        expect(@permission.admin?).to be false
      end

      it 'deleter? returns false' do
        expect(@permission.deleter?).to be false
      end
    end
  end

end
