module NotesHelper
	def note_timestamp_link(note)
		link_to(time_ago_in_words(note.created_at) + " ago", note_with_user_path(username: note.user.username, id: note.id))
	end

	def render_note(note)
		body = note.body_raw
		
		#users
		body.gsub!(/@([#{Note.username_chars}]+)(?!([a-zA-Z0-9]|:\d))/i) do |match|
			user = note.recipients.find_by(username: $1)
			user_link(user)
		end

		#entities
		body.gsub!(/@entity:(\d+)(\[([^\]]+)\])?/i) do |match|
			entity = note.entities.find($1)
			entity_link(entity, $3)
		end

		#lists
		body.gsub!(/@list:(\d+)(\[([^\]]+)\])?/i) do |match|
			list = note.lists.find($1)
			list_link(list, $3)
		end
		#groups
		body.gsub!(/@group:(\d+)(\[([^\]]+)\])?/i) do |match|
			group = note.legacy? ? note.groups.joins(:sf_guard_group).find_by("sf_guard_group.id" => $1) : note.groups.find($1)
			group_link(group, $3)
		end

		raw(body)
	end
end
