class NoteRelationship < ApplicationRecord
  belongs_to :note, inverse_of: :note_relationships
end
