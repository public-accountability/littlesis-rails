# frozen_string_literal: true

module RspecExampleHelpers
  def with_delayed_job
    Delayed::Worker.delay_jobs = false
    yield
  ensure
    Delayed::Worker.delay_jobs = true
  end

  def random_username
    Faker::Internet.unique.user_name(5).tr('.', '_')
  end

  def css(*args)
    expect(rendered).to have_css(*args)
  end

  def not_css(*args)
    expect(rendered).not_to have_css(*args)
  end

  def create_admin_user
    sf_user = FactoryBot.create(:sf_guard_user)
    create(:sf_guard_user_profile, user_id: sf_user.id)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 1, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
    user
  end

  def create_bulk_user
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 9, user_id: sf_user.id)
    user
  end

  def create_merger_user
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 7, user_id: sf_user.id)
    user
  end

  def create_list_user
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
    user
  end

  def create_contributor
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
    user
  end

  def create_importer
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 8, user_id: sf_user.id)
    user
  end

  def create_really_basic_user
    sf_user = FactoryBot.create(:sf_guard_user)
    FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
  end

  def create_basic_user_with_ids(user_id, sf_user_id)
    sf_user = FactoryBot.create(:sf_guard_user, id: sf_user_id)
    user = FactoryBot.create(:user, id: user_id, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
    user
  end

  def create_basic_user(**attributes)
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id, **attributes)
    SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
    user
  end

  def create_bulker_user
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 9, user_id: sf_user.id)
    user
  end

  def create_restricted_user
    sf_user = FactoryBot.create(:sf_guard_user)
    user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id, is_restricted: true)
    SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
    SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
    user
  end

  def create_user_with_sf(attrs = {})
    sf_user = FactoryBot.create(:sf_user)
    FactoryBot.create(:sf_guard_user_profile, user_id: sf_user.id)
    FactoryBot.create(:user, attrs.merge(sf_guard_user: sf_user))
  end

  def create_generic_relationship
    person = FactoryBot.create(:person)
    org = FactoryBot.create(:org)
    FactoryBot.create(:generic_relationship, entity: person, related: org, last_user_id: 1)
  end
end

module RspecGroupHelpers
  def assert_attribute(attr, expected)
    it "attribute \"#{attr}\" is equal to #{expected}" do
      expect(subject.send(attr)).to eql expected
    end
  end

  def assert_instance_var(instance_var, expected)
    it "instance variable \"@#{instance_var}\" is equal to #{expected}" do
      expect(subject.instance_variable_get("@#{instance_var}")).to eql expected
    end
  end

  # thanks to https://stackoverflow.com/questions/3853098/turn-off-transactional-fixtures-for-one-spec-with-rspec-2
  def without_transactional_fixtures(&block)
    self.use_transactional_tests = false

    before(:all) do
      DatabaseCleaner.strategy = :truncation
    end

    yield

    after(:all) do
      DatabaseCleaner.strategy = :transaction
    end
  end
end

class TestActiveRecord
  attr_reader :id

  def initialize
    @id = self.class.get_id
  end

  def self.get_id
    @id_counter = 0 if @id_counter.nil?
    @id_counter += 1
    @id_counter
  end

  def self.find(*args)
  end

  def self.has_many(*args)
  end
end
