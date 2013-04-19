require 'active_record'

class Image < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :entity
  
end