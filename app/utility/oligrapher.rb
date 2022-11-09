# frozen_string_literal: true

module Oligrapher
  ASSET_URL = "/oligrapher/assets"
  DISPLAY_ARROW_CATEGORIES = Set.new([Relationship::POSITION_CATEGORY,
                                      Relationship::EDUCATION_CATEGORY,
                                      Relationship::MEMBERSHIP_CATEGORY,
                                      Relationship::DONATION_CATEGORY,
                                      Relationship::OWNERSHIP_CATEGORY]).freeze

  def self.configuration(map:, current_user: nil, embed: false)
    is_owner = current_user.present? && map.user_id == current_user.id
    owner = map.user || current_user || nil

    {
      graph: map.graph_data.to_h,
      annotations: {
        currentIndex: 0,
        list: JSON.parse(map.annotations_data || "[]"),
        sources: map.sources_annotation
      },
      settings: {
        embed: embed,
        logoUrl: ActionController::Base.helpers.asset_path('lilsis-logo-trans-200.png'),
        url: Rails.application.routes.url_helpers.oligrapher_url(map)
      },
      attributes: {
        id: map.id,
        title: map.title,
        subtitle: map.description,
        date: (map.created_at || Time.current).strftime('%B %d, %Y'),
        owner: owner.present? ? { id: owner.id, name: owner.username, url: owner.url } : nil,
        user: current_user.present? ? { id: current_user.id, name: current_user.username } : nil,
        settings: settings_data(map),
        editors: is_owner ? editor_data(map) : confirmed_editor_data(map),
        shareUrl: is_owner ? map.share_path : nil,
        lock: OligrapherLockService.new(map: map, current_user: current_user).as_json
      }
    }
  end

  def self.confirmed_editor_data(map)
    User
      .where(id: map.confirmed_editor_ids)
      .map { |u| {
        name: u.username,
        url: u.url
      } }
  end

  def self.editor_data(map)
    pending_ids = map.pending_editor_ids

    User
      .where(id: map.all_editor_ids)
      .map { |u| {
        name: u.username,
        url: u.url,
        pending: pending_ids.include?(u.id)
      } }
  end

  def self.settings_data(map)
    JSON.parse(map.settings || '{}').merge({
      private: map.is_private,
      clone: map.is_cloneable,
      list_sources: map.list_sources
    })
  end

  def self.css_path(beta = false)
    "#{ASSET_URL}/#{basename(beta)}.css"
  end

  def self.javascript_path(beta = false)
    "#{ASSET_URL}/#{basename(beta)}.js"
  end

  private_class_method def self.basename(beta = false)
    commit = beta ? Rails.application.config.littlesis.oligrapher_beta :  Rails.application.config.littlesis.oligrapher_commit
    "oligrapher-" + commit
  end

  module Node
    def self.from_entity(entity)
      {
        id: entity.id.to_s,
        name: entity.name,
        description: entity.blurb,
        image: entity.featured_image&.image_url('profile'),
        url: ApplicationController.helpers.concretize_entity_url(entity)
      }
    end
  end

  def self.rel_to_edge(rel)
    {
      id: rel.id.to_s,
      node1_id: rel.entity1_id.to_s,
      node2_id: rel.entity2_id.to_s,
      label: RelationshipLabel.new(rel).label + (rel.is_current == false ? " (past)" : ""),
      arrow: edge_arrow(rel),
      dash: rel.is_current == false,
      url: relationship_url(rel)
    }
  end

  private_class_method def self.edge_arrow(rel)
    return '1->2' if DISPLAY_ARROW_CATEGORIES.include?(rel.category_id)
  end

  private_class_method def self.relationship_url(relationship)
    Rails.application.routes.url_helpers.relationship_url(relationship)
  end
end
