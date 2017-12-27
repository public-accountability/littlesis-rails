class NoteNetwork < ApplicationRecord
	belongs_to :note, inverse_of: :note_networks
	belongs_to :network, class_name: "List", inverse_of: :note_networks
end