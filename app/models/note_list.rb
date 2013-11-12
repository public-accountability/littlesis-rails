class NoteList < ActiveRecord::Base
	belongs_to :note, inverse_of: :note_lists
	belongs_to :list, inverse_of: :note_lists
end