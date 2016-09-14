class ReferenceExcerpt < ActiveRecord::Base
  include SingularTable
  validates_presence_of :body
  
  belongs_to :reference
end
