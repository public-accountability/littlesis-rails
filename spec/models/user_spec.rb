describe User do
  it { is_expected.to have_db_column(:map_the_power) }
  it { is_expected.to have_db_column(:role).of_type(:integer) }
  it { is_expected.to have_db_column(:abilities).of_type(:text) }
  it { is_expected.not_to have_db_column(:chatid) }
  it { is_expected.to have_one(:api_token) }
  it { is_expected.to have_one(:user_profile) }
  it { is_expected.to have_many(:lists) }
  it { is_expected.to have_many(:user_requests) }
  it { is_expected.to have_many(:reviewed_requests) }

  describe 'role' do
    context 'when a regular user' do
      specify { expect(build(:user).read_attribute(:role)).to eq 'user' }
      specify { expect(build(:user).role).to be User::Role::USER }
    end

    context 'when admin user' do
      specify { expect(build(:user, role: :admin).read_attribute(:role)).to eq 'admin' }
      specify { expect(build(:user, role: 1).read_attribute(:role)).to eq 'admin' }
    end

    context 'when system user' do
      specify { expect(build(:user, role: :system).read_attribute(:role)).to eq 'system' }
      specify { expect(build(:user, role: 2).read_attribute(:role)).to eq 'system' }
    end
  end

  describe 'settings' do
    specify do
      expect(build(:user).settings).to be_a UserSettings
    end
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

  describe 'delagates name to user_profile' do
    let(:user) { create_really_basic_user }
    let(:name) { Faker::Name.name }
    let!(:user_profile) do
      create(:user_profile, name: name, user: user)
    end

    specify do
      expect(user.name).to eq user_profile.name
    end
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

  describe '#restricted?' do
    it 'returns true for restircted user' do
      expect(build(:user, is_restricted: true).restricted?).to be true
    end

    it 'returns false for unrestircted user' do
      expect(build(:user, is_restricted: false).restricted?).to be false
    end
  end

  describe '#editor?' do
    specify do
      expect(build(:user, role: 'editor').editor?).to be true
      expect(build(:user, role: 'collaborator').editor?).to be true
    end
  end

  # describe '#can_edit?' do
  #   subject { user.can_edit? }

  #   context 'when user is restircted' do
  #     let(:user) { build(:user, is_restricted: true) }

  #     it { is_expected.to be false }
  #   end

  #   context 'when user is confirmed yesterday' do
  #     let(:user) { build(:user, confirmed_at: 24.hours.ago) }

  #     it { is_expected.to be true }
  #   end

  #   context 'when user is not confirmed' do
  #     let(:user) { build(:user, confirmed_at: nil) }

  #     it { is_expected.to be false }
  #   end

  #   context 'when user is confirmed 3 minutes ago' do
  #     let(:user) { build(:user, confirmed_at: 3.minutes.ago) }

  #     it { is_expected.to be false }
  #   end
  # end

  describe '#raise_unless_can_edit!' do
    let(:user) { build(:user, role: :restricted) }

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

  describe '#show_add_bulk_button?' do
    it 'returns true for admin user' do
      expect(build(:user, role: 'admin').show_add_bulk_button?).to be true
    end

    it 'returns true for collaborators' do
      expect(build(:user, role: 'collaborator').show_add_bulk_button?).to be true
    end

    it 'returns true for users with accounts older than 2 weeks and who have signed in more than 2 times' do
      user = create_editor
      user.update_columns(created_at: 1.month.ago, sign_in_count: 3)
      expect(user.show_add_bulk_button?).to be true
    end

    it 'returns false for users with accounts newer than 2 weeks' do
      user = create_editor
      user.update_columns(created_at: 1.week.ago, sign_in_count: 5)
      expect(user.show_add_bulk_button?).to be false
    end

    it 'returns false for users wwho have signed in less than 3 times' do
      user = create_editor
      user.update_columns(created_at: 3.week.ago, sign_in_count: 1)
      expect(user.show_add_bulk_button?).to be false
    end
  end
end
