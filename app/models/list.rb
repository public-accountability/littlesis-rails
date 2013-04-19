require 'active_record'

class List < ActiveRecord::Base
  include SoftDelete

  self.table_name = "ls_list"

  has_many :list_entities, -> { where is_deleted: 0 }
  has_many :entities, through: :list_entities
end