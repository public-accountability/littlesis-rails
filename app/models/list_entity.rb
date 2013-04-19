require 'active_record'

class ListEntity < ActiveRecord::Base
  self.table_name = "ls_list_entity"

  belongs_to :list, -> { where is_deleted: 0 }
  belongs_to :entity, -> { where is_deleted: 0 }
end