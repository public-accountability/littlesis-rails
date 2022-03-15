# frozen_string_literal: true

class Permissions
  ACCESS_OPEN = 0
  ACCESS_CLOSED = 1
  ACCESS_PRIVATE = 2

  ACCESS_MAPPING = {
    0 => 'Open',
    1 => 'Closed',
    2 => 'Private'
  }.freeze

  delegate(*UserAbilities::ABILITY_MAPPING.values, to: '@user.abilities')

  def initialize(user)
    @user = user
  end

  def entity_permissions(entity)
    {
      mergeable: admin?,
      deleteable: delete_entity?(entity)
    }
  end

  def relationship_permissions(rel)
    { deleteable: delete_relationship?(rel) }
  end

  def self.anon_tag_permissions
    {
      viewable: true,
      editable: false
    }
  end

  def tag_permissions(tag)
    {
      viewable: true,
      editable: edit_tag?(tag)
    }
  end

  def self.anon_list_permissions(list)
    {
      viewable: !list.restricted?,
      editable: false,
      configurable: false
    }
  end

  def list_permissions(list)
    {
      viewable: view_list?(list),
      editable: edit_list?(list),
      configurable: configure_list?(list)
    }
  end

  def show_add_bulk_button?
    @user.admin? || @user.bulker? || (@user.created_at < 2.weeks.ago && @user.sign_in_count > 2)
  end

  private

  # LIST HELPERS

  def view_list?(list)
    return true if admin? || (list.creator_user_id == @user.id)
    !list.restricted?
  end

  # Does the user have permssion to add/remove entities from given list?
  def edit_list?(list)
    return true if admin? || (list.creator_user_id == @user.id)
    !list.restricted? && @user.lister? && (list.access == ACCESS_OPEN)
  end

  def configure_list?(list)
    admin? || list.creator_user_id == @user.id
  end

  # TAG HELPERS

  def edit_tag?(tag)
    @user.admin? || !tag.restricted?
  end

  # ENTITY HELPERS

  def delete_entity?(entity)
    return true if admin? || deleter?

    entity.created_at >= 1.week.ago &&
      entity.link_count < 3 &&
      user_is_creator?(entity)
  end

  def user_is_creator?(item)
    item.versions.find_by(event: 'create')&.whodunnit == @user.id.to_s
  end

  # RELATIONSHIP HELPERS

  def delete_relationship?(rel)
    return true if admin? || deleter?
    rel.created_at >= 1.week.ago &&
      !(rel.filings.present? && rel.description1.include?('Campaign Contribution')) &&
      user_is_creator?(rel)
  end
end
