# frozen_string_literal: true

module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(is_deleted: false) }
    define_model_callbacks :soft_delete
  end

  module ClassMethods
    def active
      where(is_deleted: false)
    end

    def deleted
      unscoped.where(is_deleted: true)
    end
  end

  def soft_delete
    run_callbacks :soft_delete do
      set_paper_trail_event do
        ApplicationRecord.transaction do
          update!(is_deleted: true)
          after_soft_delete
        end
      end
    end
  end

  # This "manual" method of creating a callback via
  # implementing this function was made before
  # I found out you can create custom callbacks with
  # define_model_callbacks
  #
  # Consequently there are two ways to run code after a soft_delete:
  #   1) Implement this method `after_soft_delete`
  #   2) Use a custom method and register the callback:
  #        class Klass < ApplicationRecord
  #          after_soft_delete :my_soft_delete_method
  #        end
  #
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
