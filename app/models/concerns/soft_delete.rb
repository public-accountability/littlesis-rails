require 'active_support/concern'

module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope where(is_deleted: false)
  end
  
  module ClassMethods
    def active
      where(is_deleted: false)
    end
    
    def deleted
      where(is_deleted: true)
    end    
  end
end