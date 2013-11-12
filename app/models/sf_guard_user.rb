class SfGuardUser < ActiveRecord::Base
  include SingularTable	

  has_one :user, inverse_of: :sf_guard_user
end