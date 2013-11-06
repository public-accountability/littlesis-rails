class GroupList < ActiveRecord::Base
	belongs_to :group
	belongs_to :list

	scope :featured, -> { where(is_featured: true) }
end
