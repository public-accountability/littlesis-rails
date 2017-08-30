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

  describe "tag permisions" do

    let(:open_tagging) { build(:open_tagging) } # oil
    let(:closed_tagging) { build(:closed_tagging) } # nyc

    let(:owner) { create_really_basic_user }
    let(:non_owner) { create_really_basic_user }

    let(:full_access) { { viewable: true, editable: true } }
    let(:view_only_access) { { viewable: true, editable: false } }

    before do
      access_rules = { tag_ids: [open_tagging, closed_tagging].map(&:tag_id) }.to_json
      owner.user_permissions.create(resource_type: 'Tagging',
                                    access_rules: access_rules)
    end

    context('an open tag') do

      it('can be viewed but not edited by an anonymous user') do
        expect(
          UserPermissions::Permissions.anon_tag_permissions(open_tagging)
        ).to eq view_only_access
      end

      it("can be viewed and edited by any logged in user") do
        expect(owner.permissions.tag_permissions(open_tagging)).to eq full_access
        expect(non_owner.permissions.tag_permissions(open_tagging)).to eq full_access
      end
    end

    context('a closed tag') do

      it("can be viewed but not edited by an anonymous user") do
        expect(
          UserPermissions::Permissions.anon_tag_permissions(closed_tagging)
        ).to eq view_only_access
      end

      it("can be viewed by any logged in user but only edited by its owner(s)") do
        expect(owner.permissions.tag_permissions(closed_tagging)).to eq full_access
        expect(non_owner.permissions.tag_permissions(closed_tagging)).to eq view_only_access
      end
    end
  end

  describe "list permisions" do

    before do
      @creator = create_basic_user
      @non_creator = create_really_basic_user
      @lister = create_basic_user # basic_user === lister (see spec/support/helpers.rb)
      @admin = create_admin_user
    end

    context "an open list" do

      before do
        @open_list = build(:list, access: UserPermissions::ACCESS_OPEN, creator_user_id: @creator.id)
      end

      context "anon user" do

        it 'cannot view but not edit or configure the list' do
          expect(UserPermissions::Permissions.anon_list_permissions(@open_list))
            .to eq ({
                      viewable: true,
                      editable: false,
                      configurable: false
                    })
        end
      end

      context "logged-in creator" do

        it 'can view, edit, and configure the list' do

          expect(@creator.permissions.list_permissions(@open_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: true
                    })
        end
      end

      context "logged-in non-creator" do

        it 'can view, but no edit, or configure the list' do
          expect(@non_creator.permissions.list_permissions(@open_list))
            .to eq ({
                      viewable: true,
                      editable: false,
                      configurable: false
                    })
        end
      end

      context "lister" do

        it "can be viewed and edited, but not configured" do
          expect(@lister.permissions.list_permissions(@open_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: false
                    })
        end
      end

      context "admin" do

        it "can view, edit, and configure" do
          expect(@admin.permissions.list_permissions(@open_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: true
                    })
        end
      end #admin
    end # open list

    context 'closed list' do
      before do
        @closed_list = build(:list, access: UserPermissions::ACCESS_CLOSED, creator_user_id: @creator.id)
      end

      context "anon user" do
        it 'can view but not edit or configure the list' do
          expect(UserPermissions::Permissions.anon_list_permissions(@closed_list))
            .to eq ({
                      viewable: true,
                      editable: false,
                      configurable: false
                    })
        end
      end

      context "logged-in creator" do
        it 'can view, edit, and configure the list' do
          expect(@creator.permissions.list_permissions(@closed_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: true
                    })
        end
      end

      context "logged-in non-creator" do
        it 'can view, but no edit, or configure the list' do
          expect(@non_creator.permissions.list_permissions(@closed_list))
            .to eq ({
                      viewable: true,
                      editable: false,
                      configurable: false
                    })
        end
      end

      context "lister" do
        it "can be viewed and edited, but not configured" do
          expect(@lister.permissions.list_permissions(@closed_list))
            .to eq ({
                      viewable: true,
                      editable: false,
                      configurable: false
                    })
        end
      end

      context "admin" do
        it "can view, edit, and configure" do
          expect(@admin.permissions.list_permissions(@closed_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: true
                    })
        end
      end
    end # closed list

    context 'private list' do
      let(:all_false) do
        {
          viewable: false,
          editable: false,
          configurable: false
        }
      end

      before do
        @private_list = build(:private_list, creator_user_id: @creator.id)
      end

      context "anon user" do
        it 'can not view, eidt or configure the list' do
          expect(UserPermissions::Permissions.anon_list_permissions(@private_list)).to eq all_false
        end
      end

      context "logged-in creator" do
        it 'can view, edit, and configure the list' do
          expect(@creator.permissions.list_permissions(@private_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: true
                    })
        end
      end

      context "logged-in non-creator" do
        it 'cannot view, edit, or configure the list' do
          expect(@non_creator.permissions.list_permissions(@private_list)).to eq all_false
        end
      end

      context "lister" do
        it 'cannot view, edit, or configure the list' do
          expect(@lister.permissions.list_permissions(@private_list)).to eq all_false
        end
      end

      context "admin" do
        it "can view, edit, and configure" do
          expect(@admin.permissions.list_permissions(@private_list))
            .to eq ({
                      viewable: true,
                      editable: true,
                      configurable: true
                    })
        end
      end
    end # private list
  end
end
