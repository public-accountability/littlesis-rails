class NoteGroup < ActiveRecord::Base
	belongs_to :note
	belongs_to :group
end