class NoteRelationship < ActiveRecord::Base
	belongs_to :note
	belongs_to :relationship
end