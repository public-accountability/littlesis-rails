class NoteList < ApplicationRecord
  belongs_to :note, inverse_of: :note_lists
  belongs_to :list
end
