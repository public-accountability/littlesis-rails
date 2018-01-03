class NoteGroup < ApplicationRecord
	belongs_to :note, inverse_of: :note_groups
	belongs_to :group
end
