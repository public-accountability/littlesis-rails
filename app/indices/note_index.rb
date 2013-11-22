ThinkingSphinx::Index.define :note, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do
	indexes user.username, as: :username
	indexes recipients.username, as: :recipient_names
	indexes groups.name, as: :group_names
	indexes entities.name, as: :entity_names
	indexes lists.name, as: :list_names
	indexes body_raw

	has [is_private, user.id, recipients.id], as: :visible_to_user_ids, multi: true, type: :integer
	has user.id, as: :user_id
  has recipients.id, as: :recipient_ids
  has entities.id, as: :entity_ids
  has relationships.id, as: :relationship_ids
  has lists.id, as: :list_ids
  has networks.id, as: :network_ids
  has groups.id, as: :group_ids
  has is_private
  has created_at
end