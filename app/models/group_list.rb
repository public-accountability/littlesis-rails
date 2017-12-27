class GroupList < ApplicationRecord
	belongs_to :group, inverse_of: :group_lists
	belongs_to :list, inverse_of: :group_lists

	scope :featured, -> { where(is_featured: true) }
end
