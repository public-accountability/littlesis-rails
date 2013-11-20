module NotesHelper
	def note_timestamp_link(note)
		link_to(time_ago_in_words(note.created_at) + " ago", note_with_user_path(username: note.user.username, id: note.id))
	end

	def render_note(note)
	  return raw(note.body) if note.body.present?

		body = note.body_raw
		
		#users
		body.gsub!(/@([#{Note.username_chars}]+)(?!([a-zA-Z0-9]|:\d))/i) do |match|
			user = User.find_by(username: $1)
			user.present? ? user_link(user) : match
		end

		#entities
		body.gsub!(/@entity:(\d+)(\[([^\]]+)\])?/i) do |match|
			entity = Entity.find($1)
			entity.present? ? entity_link(entity, $3) : match
		end

		#relationships
		body.gsub!(/@rel:(\d+)(\[([^\]]+)\])?/i) do |match|
			rel = Relationship.find($1)
			rel.present? ? rel_link(rel, $3) : match
		end

		#lists
		body.gsub!(/@list:(\d+)(\[([^\]]+)\])?/i) do |match|
			list = List.find($1)
			list.present? ? list_link(list, $3) : match
		end

		#groups
		body.gsub!(/@group:(\d+)(\[([^\]]+)\])?/i) do |match|
			group = note.legacy? ? Group.joins(:sf_guard_group).find_by("sf_guard_group.id" => $1) : Group.find($1)
			group.present? ? group_link(group, $3) : match
		end

		#groups
		body.gsub!(/@group:([#{Note.username_chars}]+)/i) do |match|
			group = note.legacy? ? Group.joins(:sf_guard_group).find_by("sf_guard_group.name" => $1) : Group.find_by_slug($1)
			group.present? ? group_link(group, $3) : match
		end

		note.body = body
		note.save

		raw(note.body)
	end
end
