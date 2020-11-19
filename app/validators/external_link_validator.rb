# frozen_string_literal: true

# For some External Links, such as "crd", a single entity may have multiple
# entries. For others, such as "wikipedia," an entity can only have
# one external link of that type.
class ExternalLinkValidator < ActiveModel::Validator
  def validate(record)
    link_type = record.link_type.to_sym
    raise TypeError, 'Do not create ExternalLinks of type "reserved"' if link_type == :reserved

    return if ExternalLink::LINK_TYPES.fetch(link_type).fetch(:multiple)

    if ExternalLink.default_scoped.public_send(link_type).exists?(entity_id: record.entity_id)
      error_msg = "Entity already has an external link of type #{link_type}"
      record.errors.add :link_type, error_msg
    end
  end
end
