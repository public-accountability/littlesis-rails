require 'active_support/concern'

module SoftDelete
  extend ActiveSupport::Concern

  included do
  end
  
  module ClassMethods
    def active
      where(is_deleted: 0)
    end
  end
end