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
    set_paper_trail_event do
      self.class.transaction do
        update(is_deleted: true)
        after_soft_delete
      end
    end
  end

  def after_soft_delete
  end

  private

  def retrieve_deleted_association_data
    data = versions.where(event: 'soft_delete').last.association_data
    return nil if data.nil?
    YAML.load(data)
  end

  def set_paper_trail_event
    self.paper_trail_event = 'soft_delete' if respond_to?(:paper_trail_event)
    yield
    self.paper_trail_event = nil if respond_to?(:paper_trail_event)
  end
end
