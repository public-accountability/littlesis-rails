# frozen_string_literal: true

class UserListsPresenter
  attr_reader :users, :lists
  extend Forwardable

  def_delegator 'Rails.application.routes.url_helpers', :list_path
  def_delegators :@lists, :length, :each, :map, :[]

  UserList = Struct.new(:href, :name, :access, :created_at)

  def initialize(user)
    TypeCheck.check user, User
    @user = user
    @lists = load_lists
  end

  private

  def load_lists
    @user.lists.order(updated_at: :desc).limit(250).map do |list|
      UserList.new(
        list_path(list),
        list.name,
        Permissions::ACCESS_MAPPING[list.access],
        list.updated_at.strftime('%F')
      )
    end
  end
end
