require 'rails_helper'

describe 'User Permissions', type: :model do

  it 'user has permissions class' do
    user = create_basic_user
    expect(user.permissions).to be_a UserPermissions::Permissions
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
        expect(@permission.instance_variable_get('@sf_permissions')).to eq ['contributor', 'editor', 'lister']
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
