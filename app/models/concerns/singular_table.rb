require 'active_support/concern'

module SingularTable
  extend ActiveSupport::Concern

  included do
    self.table_name = self.name.underscore.singularize
  end
end