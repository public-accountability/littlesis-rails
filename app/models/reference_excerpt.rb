class ReferenceExcerpt < ActiveRecord::Base
  include SingularTable
  alias_attribute :excerpt, :body
  validates_presence_of :body
  
  belongs_to :reference
end
