describe Permissions, :tag_helper do
  describe 'initalizing with user with edit and list permissions' do
    let(:user) { create_basic_user }
    let(:permission) { Permissions.new(user) }

    it 'initializes with user' do
      expect(permission.instance_variable_get(:@user)).to eq user
    end

    it 'editor? returns true' do
      expect(permission.editor?).to be true
    end

    it 'lister? returns true' do
      expect(permission.lister?).to be true
    end

    it 'admin? returns false' do
      expect(permission.admin?).to be false
    end

    it 'deleter? returns false' do
      expect(permission.deleter?).to be false
    end
  end

  describe 'list permisions' do
    before do
      @creator = create_basic_user
      @non_creator = create_really_basic_user
      @lister = create_basic_user # basic_user === lister (see spec/support/helpers.rb)
      @admin = create_admin_user
    end

    context 'with an open list' do

      before do
        @open_list = build(:list, access: Permissions::ACCESS_OPEN, creator_user_id: @creator.id)
      end

      describe 'anon user' do
        it 'cannot view but not edit or configure the list' do
          expect(Permissions.anon_list_permissions(@open_list))
            .to eq(viewable: true,
                   editable: false,
                   configurable: false)
        end
      end

      context 'when logged-in as the creator' do
        it 'can view, edit, and configure the list' do
          expect(@creator.permissions.list_permissions(@open_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: true)
        end
      end

      context 'when logged-in as a non-creator' do
        it 'can view, but no edit, or configure the list' do
          expect(@non_creator.permissions.list_permissions(@open_list))
            .to eq(viewable: true,
                   editable: false,
                   configurable: false)
        end
      end

      describe 'lister' do
        it 'can be viewed and edited, but not configured' do
          expect(@lister.permissions.list_permissions(@open_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: false)
        end
      end

      describe 'admin' do
        it 'can view, edit, and configure' do
          expect(@admin.permissions.list_permissions(@open_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: true)
        end
      end # admin
    end # open list

    context 'with a closed list' do
      before do
        @closed_list = build(:list, access: Permissions::ACCESS_CLOSED, creator_user_id: @creator.id)
      end

      context 'anon user' do
        it 'can view but not edit or configure the list' do
          expect(Permissions.anon_list_permissions(@closed_list))
            .to eq(viewable: true,
                   editable: false,
                   configurable: false)
        end
      end

      context 'when logged-in as the creator' do
        it 'can view, edit, and configure the list' do
          expect(@creator.permissions.list_permissions(@closed_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: true)
        end
      end

      context 'when logged-in as the non-creator' do
        it 'can view, but no edit, or configure the list' do
          expect(@non_creator.permissions.list_permissions(@closed_list))
            .to eq(viewable: true,
                   editable: false,
                   configurable: false)
        end
      end

      describe 'lister' do
        it 'can be viewed and edited, but not configured' do
          expect(@lister.permissions.list_permissions(@closed_list))
            .to eq(viewable: true,
                   editable: false,
                   configurable: false)
        end
      end

      describe 'admin' do
        it 'can view, edit, and configure' do
          expect(@admin.permissions.list_permissions(@closed_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: true)
        end
      end
    end # closed list

    context 'with a private list' do
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

      describe 'anon user' do
        it 'can not view, eidt or configure the list' do
          expect(Permissions.anon_list_permissions(@private_list)).to eq all_false
        end
      end

      context 'when logged-in as the creator' do
        it 'can view, edit, and configure the list' do
          expect(@creator.permissions.list_permissions(@private_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: true)
        end
      end

      context 'when logged-in as a non-creator' do
        it 'cannot view, edit, or configure the list' do
          expect(@non_creator.permissions.list_permissions(@private_list)).to eq all_false
        end
      end

      describe 'lister' do
        it 'cannot view, edit, or configure the list' do
          expect(@lister.permissions.list_permissions(@private_list)).to eq all_false
        end
      end

      describe 'admin' do
        it 'can view, edit, and configure' do
          expect(@admin.permissions.list_permissions(@private_list))
            .to eq(viewable: true,
                   editable: true,
                   configurable: true)
        end
      end
    end # private list
  end # list permissions

  describe 'relationship permissions' do
    subject { permissions.relationship_permissions(relationship) }

    let(:abilities) { UserAbilities.new(:edit) }
    let(:user) { build(:user, abilities: abilities) }
    let(:relationship) { build(:generic_relationship, created_at: Time.current) }
    let(:permissions) { Permissions.new(user) }

    let(:legacy_permissions) { [] }

    context 'when the user created the relationship' do
      before do
        allow(permissions).to receive(:user_is_creator?)
                                .with(relationship)
                                .and_return(true)
      end

      context 'when relationship is new' do
        specify { expect(subject[:deleteable]).to be true }
      end

      context 'when the relationship is more than a week old' do
        let(:relationship) { build(:generic_relationship, created_at: 2.weeks.ago) }
        specify { expect(subject[:deleteable]).to be false }
      end

      context 'when the relationship is a campaign contribution' do
        let(:relationship) do
          build(:donation_relationship,
                created_at: Time.current,
                description1: 'NYS Campaign Contribution',
                filings: 2)
        end

        specify { expect(subject[:deleteable]).to be false }
      end
    end

    context 'when the user did not create the relationship' do
      before do
        expect(permissions).to receive(:user_is_creator?)
                                .with(relationship)
                                .and_return(false)
      end

      context 'when relationship is new' do
        specify { expect(subject[:deleteable]).to be false }
      end
    end

    context 'when user is a deleter' do
      let(:abilities) { UserAbilities.new(:edit, :delete) }

      specify { expect(subject[:deleteable]).to be true }
    end

    context 'when user is an admin' do
      let(:abilities) { UserAbilities.new(:edit, :admin) }

      context 'when relationship is new' do
        specify { expect(subject[:deleteable]).to be true }
      end
    end
  end
end
