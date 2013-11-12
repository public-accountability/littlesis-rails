class List < ActiveRecord::Base
  self.table_name = "ls_list"

  include SoftDelete

  has_many :list_entities, inverse_of: :list, dependent: :destroy
  has_many :entities, through: :list_entities
  has_many :images, through: :entities

  has_many :users, inverse_of: :default_network
  has_many :default_groups, inverse_of: :default_network
  has_many :featured_in_groups, class_name: "Group", inverse_of: :featured_list

  has_many :group_lists, inverse_of: :list
  has_many :groups, through: :group_lists, inverse_of: :lists

  has_many :note_lists, inverse_of: :list
  has_many :notes, through: :note_lists, inverse_of: :lists

  def network?
  	@is_network
  end
end