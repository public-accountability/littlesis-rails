class NoteEntity < ActiveRecord::Base
	belongs_to :note
	belongs_to :entity
end