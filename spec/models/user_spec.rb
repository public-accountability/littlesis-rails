describe User do
  it { is_expected.to have_db_column(:map_the_power) }
  it { is_expected.to have_db_column(:role).of_type(:integer) }
  it { is_expected.to have_db_column(:abilities).of_type(:text) }
  it { is_expected.not_to have_db_column(:chatid) }
  it { is_expected.to have_one(:api_token) }
  it { is_expected.to have_one(:user_profile) }
  it { is_expected.to have_many(:lists) }
  it { is_expected.to have_many(:user_permissions) }
  it { is_expected.to have_many(:user_requests) }
  it { is_expected.to have_many(:reviewed_requests) }

  describe 'role' do
    context 'when a regular user' do
      specify { expect(build(:user).role).to eq 'user' }
    end

    context 'when admin user' do
      specify { expect(build(:user, role: :admin).role).to eq 'admin' }
      specify { expect(build(:user, role: 1).role).to eq 'admin' }
    end

    context 'when system user' do
      specify { expect(build(:user, role: :system).role).to eq 'system' }
      specify { expect(build(:user, role: 2).role).to eq 'system' }
    end
  end

  describe 'abilities' do
    let(:user) { create(:user) }

    it 'serializes UserAbilities' do
      expect(build(:user).abilities).to be_a UserAbilities
    end

    describe 'adding and removing abilities' do
      it 'adds a new ability' do
        expect { user.add_ability(:merge) }
          .to change { user.reload.abilities.to_set }
                .from(Set[:edit]).to(Set[:edit, :merge])
      end

      it 'adds an ability using save' do
        user = build(:user)
        expect(user).to receive(:save).once
        user.add_ability(:edit)
      end

      it 'removes an ability using save' do
        user = build(:user)
        expect(user).to receive(:save).once
        user.remove_ability(:edit)
      end

      it 'adds an ability using save!' do
        user = build(:user)
        expect(user).to receive(:save!).once
        user.add_ability!(:edit)
      end

      it 'removes an ability using save!' do
        user = build(:user)
        expect(user).to receive(:save!).once
        user.remove_ability!(:edit)
      end

      it 'removes an ability' do
        user.add_ability(:edit, :bulk)
        expect { user.remove_ability(:bulk) }
          .to change { user.reload.abilities.to_set }
                .from(Set[:edit, :bulk]).to(Set[:edit])
      end

      it 'adds two abilities at once' do
        expect { user.add_ability(:bulk, :merge) }
          .to change { user.reload.abilities.to_set }
                .from(Set[:edit]).to(Set[:bulk, :merge, :edit])
      end
    end
  end

  describe 'settings' do
    specify do
      expect(build(:user).settings).to be_a UserSettings
    end
  end

  it 'user has permissions class' do
    user = create_basic_user
    expect(user.permissions).to be_a Permissions
  end

  describe 'validations' do
    let(:user) { create_basic_user(username: 'unqiue2') }

    it 'validates presence of email' do
      expect(user.valid?).to be true
      expect(build(:really_basic_user, email: nil).valid?).to be false
    end

    it 'validates uniqueness of email' do
      invalid_user = build(:really_basic_user, email: user.email)
      valid_user = build(:really_basic_user, email: Faker::Internet.unique.email)
      [invalid_user, valid_user].each(&:valid?)
      expect(invalid_user.errors[:email]).to eq(["has already been taken"])
      expect(valid_user.errors[:email]).to eq([])
    end

    describe 'username validation' do
      context 'with valid username' do
        let(:user) { build(:really_basic_user, username: 'f_kafka') }

        specify { expect(user.valid?).to be true }
      end

      context 'with invalid username' do
        let(:user) { build(:really_basic_user, username: 'f.kafka') }

        specify { expect(user.valid?).to be false }
      end
    end
  end

  describe 'delagates first and last names to user_profile' do
    let(:user) { create_really_basic_user }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:user_profile) do
      create(:user_profile, name_first: first_name, name_last: last_name, user: user)
    end

    before { user_profile }

    specify { expect(user.name_first).to eql user_profile.name_first }
    specify { expect(user.name_last).to eql user_profile.name_last }
    specify { expect(user.full_name).to eq "#{first_name} #{last_name}" }
  end

  describe 'set_default_network_id' do
    let(:user) do
      User.new(email: Faker::Internet.unique.email,
               username: random_username)
    end

    it 'sets default network id to be the magic number 79' do
      user.valid?
      expect(user.default_network_id).to eq 79
    end
  end

  describe 'create_default_permissions' do
    let(:user) { create(:user, abilities: UserAbilities.new) }

    before { user }

    it 'adds "edit" ability' do
      expect { user.create_default_permissions }
        .to change { user.abilities.abilities }
              .from(Set.new).to(Set[:edit])
    end
  end

  describe 'has_ability?' do
    let(:permissions) { [] }
    let(:user) { build(:user, abilities: UserAbilities.new(*permissions)) }

    def self.assert_user_has_permission(permission)
      specify { expect(user.has_ability?(permission)).to be true }
    end

    def self.assert_user_does_not_have_permission(permission)
      specify { expect(user.has_ability?(permission)).to be false }
    end

    context 'when user only has edit ability' do
      let(:permissions) { %i[edit] }

      assert_user_has_permission :edit
      assert_user_has_permission 'edit'
      assert_user_has_permission 'editor'
      assert_user_has_permission 'contributor'
      assert_user_does_not_have_permission 'admin'
      assert_user_does_not_have_permission 'bulker'
      assert_user_does_not_have_permission 'deleter'
    end

    context 'when user has edit and bulk ability' do
      let(:permissions) { %i[edit bulk] }

      assert_user_has_permission 'editor'
      assert_user_does_not_have_permission 'admin'
      assert_user_has_permission :bulk
      assert_user_has_permission 'bulk'
      assert_user_has_permission 'bulker'
      assert_user_has_permission 'importer'
      assert_user_does_not_have_permission :delete
      assert_user_does_not_have_permission 'delete'
      assert_user_does_not_have_permission 'deleter'
      assert_user_does_not_have_permission 'lister'
    end

    context 'when user has admin ability' do
      let(:permissions) { %i[admin] }

      assert_user_has_permission :admin

      %w[admin bulker merger deleter].each do |p|
        assert_user_has_permission(p)
      end
    end

    context 'when user has delete ability' do
      let(:permissions) { %i[edit delete] }

      assert_user_has_permission 'deleter'
      assert_user_does_not_have_permission 'admin'
    end

    context 'when user has merger ability' do
      let(:permissions) { %i[edit merge delete] }

      assert_user_has_permission 'merger'
      assert_user_does_not_have_permission 'admin'
    end
  end

  describe '#recent_edits' do
    let(:user) { create_really_basic_user }

    it 'returns UserEdits::Edits' do
      expect(user.recent_edits).to be_a UserEdits::Edits
      expect(user.recent_edits(2)).to be_a UserEdits::Edits
    end
  end

  describe '#admin?' do
    let(:admin_user) { create_admin_user }
    let(:user) { create_really_basic_user }

    specify { expect(admin_user.admin?).to be true }
    specify { expect(user.admin?).to be false }
  end

  describe '#importer?' do
    let(:importer) do
      create(:user, abilities: UserAbilities.new(:edit, :bulk))
    end
    let(:user) { create_really_basic_user }

    specify { expect(importer.importer?).to be true }
    specify { expect(user.importer?).to be false }
  end

  describe '#bulker?' do
    let(:bulker) do
      create(:user, abilities: UserAbilities.new(:edit, :bulk))
    end
    let(:user) { create_really_basic_user }

    specify { expect(bulker.bulker?).to be true }
    specify { expect(user.bulker?).to be false }
  end

  describe '#merger?' do
    let(:merger) do
      create(:user, abilities: UserAbilities.new(:edit, :merge))
    end
    let(:user) { create_really_basic_user }

    specify { expect(merger.merger?).to be true }
    specify { expect(user.merger?).to be false }
  end

  describe '#restricted?' do
    it 'returns true for restircted user' do
      expect(build(:user, is_restricted: true).restricted?).to be true
    end

    it 'returns false for unrestircted user' do
      expect(build(:user, is_restricted: false).restricted?).to be false
    end
  end

  describe '#can_edit?' do
    subject { user.can_edit? }

    context 'when user is restircted' do
      let(:user) { build(:user, is_restricted: true) }

      it { is_expected.to be false }
    end

    context 'when user is confirmed yesterday' do
      let(:user) { build(:user, confirmed_at: 24.hours.ago) }

      it { is_expected.to be true }
    end

    context 'when user is not confirmed' do
      let(:user) { build(:user, confirmed_at: nil) }

      it { is_expected.to be false }
    end

    context 'when user is confirmed 3 minutes ago' do
      let(:user) { build(:user, confirmed_at: 3.minutes.ago) }

      it { is_expected.to be false }
    end
  end

  describe '#raise_unless_can_edit!' do
    let(:user) { build(:user, is_restricted: true) }

    it 'raises UserCannotEditErorr' do
      expect { user.raise_unless_can_edit! }
        .to raise_error(Exceptions::UserCannotEditError)
    end
  end

  describe 'User.matches_username_or_email' do
    it 'returns Arel query' do
      expect(User.matches_username_or_email('example'))
        .to be_a Arel::Nodes::Grouping
    end

    it 'returns nil if input is nil' do
      expect(User.matches_username_or_email(nil)).to be nil
    end
  end

  describe 'User.derive_last_user_id_from' do
    it 'accepts strings and integer' do
      expect(User.derive_last_user_id_from('123')).to eq 123
      expect(User.derive_last_user_id_from(123)).to eq 123
    end

    it 'accepts User' do
      user = build(:user)
      expect(User.derive_last_user_id_from(user)).to eq user.id
    end

    it 'by default it raises TypeError if provided nil' do
      expect { User.derive_last_user_id_from(nil) }
        .to raise_error(TypeError)
    end

    it 'returns system_user_id if allow_invalid is set' do
      expect { User.derive_last_user_id_from(Object.new, allow_invalid: true) }
        .not_to raise_error

      expect(User.derive_last_user_id_from(nil, allow_invalid: true)).to eq 1
    end
  end

  describe 'system_users' do
    it 'returns the system users' do
      expect(User.system_users).to eq [User.find(1)]
    end

    it 'stores result in rails cache' do
      expect(Rails.cache).to receive(:fetch)
                               .with('user/system_users', hash_including(:expires_in))
                               .once
      User.system_users
    end
  end

  describe 'User.valid_username?' do
    subject { User.valid_username?(name) }

    context 'with invalid username' do
      let(:name) { '!x' }

      it { is_expected.to be false }
    end

    context 'with valid username' do
      let(:name) { FactoryBot.attributes_for(:user)[:username] }

      it { is_expected.to be true }
    end

    context 'with already taken username' do
      let(:user) { create_basic_user }
      let(:name) { user.username }

      before { user }

      it { is_expected.to be false }
    end

    context 'with aLtErNaTiNg capitalization of existing username' do
      let(:user) { create_basic_user }
      let(:name) do
        user.username.split('').map.with_index { |x, i| i.even? ? x.upcase : x }.join('')
      end

      before { user }

      specify do
        expect(User.valid_username?(name)).to be false
      end
    end
  end

  describe '#image_url' do
    specify { expect(build(:user).image_url).to match /\/assets\/system\/anon/ }
  end
end
