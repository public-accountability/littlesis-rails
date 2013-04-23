require 'active_record'

class List < ActiveRecord::Base
  self.table_name = "ls_list"

  include SoftDelete

  has_many :list_entities, inverse_of: :list, dependent: :destroy
  has_many :entities, through: :list_entities
  has_many :images, through: :entities
end