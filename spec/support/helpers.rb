def css(*args)
  expect(rendered).to have_css(*args)
end

def not_css(*args)
  expect(rendered).not_to have_css(*args)
end

# thanks to https://stackoverflow.com/questions/3853098/turn-off-transactional-fixtures-for-one-spec-with-rspec-2
def without_transactional_fixtures(&block)
  self.use_transactional_fixtures = false

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  yield

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end
end


def create_admin_user
  sf_user = FactoryGirl.create(:sf_guard_user, sf_guard_user_profile: build(:sf_guard_user_profile))
  user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 1, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
  user
end

def create_bulk_user
  sf_user = FactoryGirl.create(:sf_guard_user)
  user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 9, user_id: sf_user.id)
  user
end

def create_list_user
  sf_user = FactoryGirl.create(:sf_guard_user)
  user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
  user
end

def create_contributor
  sf_user = FactoryGirl.create(:sf_guard_user)
  user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
  user
end

def create_basic_user
  sf_user = FactoryGirl.create(:sf_guard_user)
  user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
  user
end

def create_restricted_user
  sf_user = FactoryGirl.create(:sf_guard_user)
  user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id, is_restricted: true)
  SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
  SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
  user
end

def create_user_with_sf(attrs = {})
  sf_user = FactoryGirl.create(:sf_user)
  FactoryGirl.create(:sf_guard_user_profile, user_id: sf_user.id)
  FactoryGirl.create(:user, attrs.merge(sf_guard_user: sf_user))
end
