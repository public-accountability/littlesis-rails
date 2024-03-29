# frozen_string_literal: true

# Permissions object for entities
Entity::Permissions = Struct.new(:mergeable, :deleteable, keyword_init: true) do
  # @param user [User, Nil]
  # @param entity [Entity]
  def initialize(user:, entity:)
    super(mergeable: user.present? && user.admin?,
          deleteable: entity.deleteable_by?(user))
  end
end
