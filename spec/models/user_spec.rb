require 'rails_helper'

describe User do
  it { is_expected.to have_db_column(:map_the_power) }
  it { is_expected.to have_db_column(:role).of_type(:integer) }
  it { is_expected.to have_db_column(:abilities).of_type(:text) }
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
    let(:user) { create(:user, sf_guard_user: create(:sf_guard_user)) }

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

  it 'has constant User::Edits (from module UserEdits)' do
    expect(User.const_defined?(:Edits)).to be true
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
      expect(build(:really_basic_user, email: user.email).valid?). to be false
      expect(build(:really_basic_user, email: Faker::Internet.unique.email).valid?). to be true
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

    describe 'sf_guard' do
      subject { build(:user, sf_guard_user_id: rand(1000)) }

      it { is_expected.to validate_uniqueness_of(:sf_guard_user_id) }
      it { is_expected.to validate_presence_of(:sf_guard_user_id) }
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
      User.new(sf_guard_user_id: rand(1000),
               email: Faker::Internet.unique.email,
               username: random_username)
    end

    it 'sets default network id to be the app config default' do
      user.valid?
      expect(user.default_network_id).to eql APP_CONFIG.fetch('default_network_id')
    end
  end

  describe 'legacy_check_password' do
    let(:sf_user) { create(:sf_guard_user, salt: 'SALT', password: Digest::SHA1.hexdigest('SALTPEANUTS')) }
    let(:user) { create(:user, username: 'unique', sf_guard_user_id: sf_user.id) }

    it 'returns true for correct password' do
      expect(user.legacy_check_password('PEANUTS')).to be true
    end

    it 'returns false for incorrect password' do
      expect(user.legacy_check_password('FAKE_PEANUTS')).to be false
    end
  end

  describe 'create_default_permissions' do
    let(:sf_user) { create(:sf_guard_user) }
    let(:user) { create(:user, sf_guard_user_id: sf_user.id, abilities: UserAbilities.new) }

    before { user }

    it 'adds "edit" ability' do
      expect { user.create_default_permissions }
        .to change { user.abilities.abilities }
              .from(Set.new).to(Set[:edit])
    end

    it 'creates contributor permission' do
      expect(user.has_legacy_permission('contributor')).to be false
      user.create_default_permissions
      expect(user.has_legacy_permission('contributor')).to be true
    end

    it 'creates editor permission' do
      expect(user.has_legacy_permission('editor')).to be false
      user.create_default_permissions
      expect(user.has_legacy_permission('editor')).to be true
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

    describe 'aliases method as has_legacy_permission' do
      let(:permissions) { %i[edit] }

      specify { expect(user.has_legacy_permission('editor')).to be true }
      specify { expect(user.has_legacy_permission('admin')).to be false }
    end

    describe 'unused legacy permissions' do
      let(:permissions) { %i[edit] }

      assert_user_does_not_have_permission 'talker'
      assert_user_does_not_have_permission 'contacter'
    end

    context 'when user only has edit ability' do
      let(:permissions) { %i[edit] }

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
      assert_user_has_permission 'bulker'
      assert_user_has_permission 'importer'
      assert_user_does_not_have_permission 'deleter'
      assert_user_does_not_have_permission 'lister'
    end

    context 'when user has admin ability' do
      let(:permissions) { %i[admin] }

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

  describe 'chat user' do
    let(:user) { build(:user) }

    describe 'create_chat_account' do
      it 'returns :existing_account if user has chatid' do
        expect(build(:user, chatid: '12345').create_chat_account).to be :existing_account
      end

      it 'creates account' do
        expect(Chat).to receive(:create_user).once.with(user)
        user.create_chat_account
      end
    end
  end

  describe '#recent_edits' do
    let(:user) { create_really_basic_user }

    it 'returns User::Edits' do
      expect(user.recent_edits).to be_a User::Edits
      expect(user.recent_edits(2)).to be_a User::Edits
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
      sf_user = create(:sf_guard_user)
      create(:user, sf_guard_user_id: sf_user.id, abilities: UserAbilities.new(:edit, :bulk))
    end
    let(:user) { create_really_basic_user }

    specify { expect(importer.importer?).to be true }
    specify { expect(user.importer?).to be false }
  end

  describe '#bulker?' do
    let(:bulker) do
      sf_user = create(:sf_guard_user)
      create(:user, sf_guard_user_id: sf_user.id, abilities: UserAbilities.new(:edit, :bulk))
    end
    let(:user) { create_really_basic_user }

    specify { expect(bulker.bulker?).to be true }
    specify { expect(user.bulker?).to be false }
  end

  describe '#merger?' do
    let(:merger) do
      sf_user = create(:sf_guard_user)
      create(:user, sf_guard_user_id: sf_user.id, abilities: UserAbilities.new(:edit, :merge))
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
      user = build(:user, sf_guard_user_id: 123)
      expect(User.derive_last_user_id_from(user)).to eq 123
    end

    it 'accepts SfGuardUser' do
      sf_user = build(:sf_user, id: 456)
      expect(User.derive_last_user_id_from(sf_user)).to eq 456
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

      it { is_expected.to be false }
    end

  end

  describe '#image_url' do
    specify { expect(build(:user).image_url).to eq '/images/system/anon.png' }
  end
end
