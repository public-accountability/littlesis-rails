# frozen_string_literal: true

module RspecHelpers
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

  module ExampleMacros
    def self.create_admin_user
      FactoryBot.create(:user, role: 'admin').tap do |user|
        FactoryBot.create(:user_profile, user: user)
      end
    end

    def self.create_basic_user(**attributes)
      FactoryBot.create(:user, **attributes, role: :user)
    end

    def self.create_restricted_user
      FactoryBot.create(:user, is_restricted: true, role: :restricted)
    end

    def self.create_collaborator
      FactoryBot.create(:user, role: :collaborator)
    end

    def with_versioning_for(user_or_id)
      TypeCheck.check user_or_id, [User, String, Integer]
      user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id

      with_versioning do
        PaperTrail.request(whodunnit: user_id.to_s) do
          yield
        end
      end
    end

    def valid_json?(json)
      JSON.parse(json)
      true
    rescue JSON::ParserError
      false
    end

    def random_username
      Faker::Internet.unique.user_name(specifier: 5).tr('.', '_')
    end

    def css(...)
      expect(rendered).to have_css(...)
    end

    def not_css(...)
      expect(rendered).not_to have_css(...)
    end

    def create_basic_user(**attributes)
      ExampleMacros.create_basic_user(**attributes)
    end

    def create_admin_user
      ExampleMacros.create_admin_user
    end

    def create_collaborator
      ExampleMacros.create_collaborator
    end

    def create_really_basic_user
      FactoryBot.create(:user)
    end

    def create_basic_user_with_profile(**attributes)
      create_basic_user(**attributes).tap do |user|
        user.create_user_profile!(FactoryBot.attributes_for(:user_profile))
      end
    end

    def create_restricted_user
      ExampleMacros.create_restricted_user
    end

    # def create_user(attrs = {})
    #   user = FactoryBot.create(:user, attrs)
    #   create(:user_profile, user: user)
    #   user
    # end

    def within_one_second?(a, b)
      [0, 1].include? (a.to_i - b.to_i).abs
    end

    # Useful to reload modules or classes if they depend on other constants during loading.
    # If ImageFile depended on the constant FOO, this is how  to set FOO and reload ImageFile:
    #
    #  stub_const_and_reload_module const: 'FOO', val: 'fake foo value', mod: :ImageFile
    #
    def stub_const_and_reload_module(const:, val:, mod:)
      stub_const const, val
      Object.send :remove_const, mod if Module.const_defined?(mod)
      load mod.to_s.underscore
    end
  end

  module GroupMacros
    def assert_attribute(attr, expected)
      it "attribute \"#{attr}\" is equal to #{expected}" do
        if subject.is_a?(Hash)
          expect(subject.send(:fetch, attr)).to eq expected
        else
          expect(subject.send(attr)).to eq expected
        end
      end
    end

    def assert_method_call(method, expected, args = [])
      it "calling method #{method} is equal to #{expected}" do
        expect(subject.send(method, *args)).to eq expected
      end
    end

    def assert_instance_var(instance_var, expected)
      it "instance variable \"@#{instance_var}\" is equal to #{expected}" do
        expect(subject.instance_variable_get("@#{instance_var}")).to eql expected
      end
    end

    def describe_unless_on_ci(...)
      if ENV['CI']
        xdescribe(...)
      else
        describe(...)
      end
    end
  end
end
