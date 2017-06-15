class NoteGroup < ActiveRecord::Base
	belongs_to :note, inverse_of: :note_groups
	belongs_to :group
end
