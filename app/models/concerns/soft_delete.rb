require 'active_support/concern'

module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(is_deleted: false) }
    scope :active, -> { where(is_deleted: false) }
    scope :deleted, -> { where(is_deleted: true) }
  end
  
  module ClassMethods
    def active
      where(is_deleted: false)
    end
    
    def deleted
      where(is_deleted: true)
    end    
  end

  def soft_delete
    self.class.transaction do  
      update(is_deleted: true)
      after_soft_delete
    end
  end

  def after_soft_delete
  end
end