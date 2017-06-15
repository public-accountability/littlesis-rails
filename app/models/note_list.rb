class NoteList < ActiveRecord::Base
  belongs_to :note, inverse_of: :note_lists
  belongs_to :list
end
