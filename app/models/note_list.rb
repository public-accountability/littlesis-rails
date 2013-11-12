class NoteList < ActiveRecord::Base
	belongs_to :note
	belongs_to :list
end