class SfGuardUser < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  has_one :user, inverse_of: :sf_guard_user
end