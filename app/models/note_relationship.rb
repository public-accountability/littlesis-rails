class NoteRelationship < ActiveRecord::Base
	belongs_to :note, inverse_of: :note_relationships
	# belongs_to :relationship, inverse_of: :note_relationships
end
