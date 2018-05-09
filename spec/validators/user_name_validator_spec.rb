require 'rails_helper'

describe UserNameValidator do
  class UserNameTester <
    include ActiveModel::Validations
    attr_accessor :username
    validates :username, user_name: true
  end

  let(:username) { '' }

  subject do
    UserNameTester.new.tap { |x| x.username = username }
  end

  def self.test_user_name(name, valid)
    context "with username: #{name}" do
      let(:username) { name }
      specify { expect(subject.valid?).to be valid }
    end
  end

  test_user_name('', false)
  test_user_name('ab', false)
  test_user_name('1username', false)
  test_user_name('username123', true)
  test_user_name('Nikola', true)
  test_user_name('user_name', true)
  test_user_name('user name', false)
  test_user_name('username!', false)
  test_user_name('user.name', false)
end
