# frozen_string_literal: true

# For some External Links, such as "crd", a single entity may have multiple 
# entries. For others, such as "wikipedia," an entity can only have
# one external link of that type.
class ExternalLinkValidator < ActiveModel::Validator
  def validate(record)
    return if ExternalLink::MULTIPLE_VALUES_ALLOWED.include? record.link_type.to_sym

    if ExternalLink.exists? link_type: record.link_type, entity_id: record.entity_id
      error_msg = "Entity already has an external link of type #{record.link_type}"
      record.errors.add :link_type, error_msg
    end
  end
end
