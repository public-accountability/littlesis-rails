# frozen_string_literal: true

# rubocop:disable Rails/SafeNavigation

class NetworkMap < ApplicationRecord
  include SoftDelete

  ThinkingSphinx::Callbacks.append(self, :behaviours => [:real_time])

  LS_DATA_SOURCE_BASE_URL = "#{Rails.application.default_url_options[:protocol]}://#{Rails.application.default_url_options[:host]}"

  attribute :graph_data, OligrapherGraphData::Type.new
  serialize :editors, Array

  has_paper_trail on: [:update, :destroy], skip: [:screenshot]

  delegate :url_helpers, to: 'Rails.application.routes'

  belongs_to :user, inverse_of: :network_maps, optional: true

  scope :featured, -> { where(is_private: false, is_featured: true) }
  scope :public_scope, -> { where(is_private: false) }
  scope :private_scope, -> { where(is_private: true) }
  # scope :with_description, -> { where.not(description: [nil, '']) }
  # scope :with_annotations, -> { where.not(annotations_data: '[]') }
  # scope :without_annotations, -> { where(annotations_data: '[]') }

  validates :title, presence: true

  before_create :generate_secret, :set_defaults

  before_save :set_index_data
  before_save :start_update_entity_network_map_collections_job, if: :update_network_map_collection?

  def set_index_data
    self.index_data = generate_index_data
  end

  # TODO: simplify and rewrite this
  def generate_index_data
    entities_text = entities.pluck(:name, :blurb).flatten.compact.join(', ')
    return entities_text if captions.blank?

    if oligrapher_version == 3
      captions_text = captions.map { |c| c['text'] }.join(', ')
    else
      captions_text = captions.map { |c| c['display']['text'] }.join(', ')
    end
    "#{entities_text}, #{captions_text}"
  end

  def destroy
    soft_delete
  end

  def set_defaults
    self.width = 960 if width.blank?
    self.height = 550 if height.blank?
    self.zoom = '1' if zoom.blank?
  end

  def generate_secret
    self.secret = SecureRandom.hex(10)
  end

  def cloneable?
    is_cloneable && !is_private
  end

  def documents
    @_documents ||= Reference
                      .includes(:document)
                      .where(referenceable_id: rels.map(&:id), referenceable_type: 'Relationship')
                      .order(updated_at: :desc)
                      .map(&:document)
                      .uniq
                      .reject { |d| d.name.blank? }
  end

  def name
    return "Map #{id}" if title.blank?

    title
  end

  def to_param
    title.nil? ? id.to_s : "#{id}-#{title.parameterize}"
  end

  def documents_to_html
    documents.map { |d| "<div><a href=\"#{d.url}\">#{d.name}</a></div>"}.join("\n")
  end

  def screenshot_path
    Rails.root.join('public/images/oligrapher', "#{id}.png")
  end

  def screenshot_exists?
    File.file?(screenshot_path)
  end

  def take_screenshot
    if is_private?
      Rails.logger.debug { "Cannot take a screenshot of a private map (#{id})" }
      return nil
    end
    system "#{Rails.root.join('lib/scripts/oligrapher_screenshot.js')} #{url}"
  end

  # enques job to take screenshot
  # OligrapherScreenshotJob.perform_later(id)

  # Creates these functions:
  #  edge_ids, node_ids, numeric_edge_ids, numeric_node_ids
  %i[edge node].each do |graph_component|
    # -> Array[String]
    define_method("#{graph_component}_ids") do |data|
      case data
      when String
        hash = JSON.parse(data)
      when OligrapherGraphData, Hash
        hash = data.to_h
      else
        raise TypeError
      end
      hash[graph_component.to_s.pluralize].keys
    end

    # -> Array[String]
    define_method("numeric_#{graph_component}_ids") do |data = nil|
      send("#{graph_component}_ids", data.blank? ? graph_data : data)
        .select { |id| id.to_s.match(/^\d+$/) }
    end
  end

  # -> Relationship::ActiveRecord_Relation | Array
  def rels
    return [] if numeric_edge_ids.empty?

    Relationship.where(id: numeric_edge_ids)
  end

  # -> Relationship::ActiveRecord_Relation | Array
  def entities
    return [] if numeric_node_ids.empty?

    Entity.where(id: numeric_node_ids)
  end

  def captions
    graph_data['captions'].values
  end

  def annotations_data_with_sources
    annotations = JSON.parse(annotations_data)

    if list_sources && documents.count.positive?
      annotations.concat([sources_annotation])
    end

    JSON.dump(annotations)
  end

  def sources_annotation
    return nil unless documents.count.positive?

    {
      id: 'sources',
      nodeIds: [],
      edgeIds: [],
      captionIds: [],
      header: 'Sources',
      text: documents_to_html
    }
  end

  def entities_removed_from_graph
    if graph_data_changed?
      new_nodes = numeric_node_ids.map(&:to_i).to_set
      old_nodes = numeric_node_ids(graph_data_was).map(&:to_i).to_set
      return old_nodes.difference(new_nodes).to_a
    end
    []
  end

  # Used in view as oligrapher title
  # - appends lock icon if map is private and lock is set to true
  def display_title(lock: false)
    if lock && is_private
      "#{title} \u{1F512}".to_json
    else
      title.to_json
    end
  end

  def share_path
    return nil unless persisted?
    url_helpers.share_oligrapher_path(id: id, secret: secret)
  end

  def version3?
    oligrapher_version == 3
  end

  # Editor methods
  # These are only for oligrapher version 3
  def confirmed_editor_ids
    editors.reject { |e| e[:pending] }.map { |e| e[:id] }
  end

  def pending_editor_ids
    editors.filter { |e| e[:pending] }.map { |e| e[:id] }
  end

  def all_editor_ids
    editors.map { |e| e[:id] }
  end

  def add_editor(editor)
    editor_id = editor.try(:id) || editor.try!(:to_i)
    return self if all_editor_ids.include?(editor_id)
    return self if user_id == editor_id

    if validate_editor(editor_id)
      editors << { id: editor_id, pending: true }
      editors_will_change!
    end

    self
  end

  def remove_editor(editor)
    editor_id = editor.try(:id) || editor.try!(:to_i)

    self.editors.reject! { |e| e[:id] == editor_id }
    editors_will_change!

    self
  end

  def confirm_editor(editor)
    editor_id = editor.try(:id) || editor.try!(:to_i)

    editors.map! do |e|
      if e[:id] == editor_id
        e.merge({ pending: false })
      else
        e
      end
    end

    self
  end

  def validate_editor(editor_id)
    if User.exists?(id: editor_id)
      true
    else
      Rails.logger.info "[NetworkMap] Could not find editor #{editor_id} in the database"
      false
    end
  end

  def can_edit?(user)
    return false if user.blank?

    editor_id = user.try(:id) || user.try!(:to_i)
    editor_id == user_id or confirmed_editor_ids.include?(editor_id)
  end

  def has_pending_editor?(user)
    return false if user.blank?

    pending_editor_ids.include?(user.id)
  end

  def url
    LittleSis::Application.routes.url_helpers.oligrapher_url(self)
  end

  # input: <User> --> NetworkMap::ActiveRecord_Relation
  def self.scope_for_user(user)
    where arel_table[:is_private].eq(false)
            .or(arel_table[:user_id].eq(user.id))
  end

  def self.index_maps
    Rails.cache.fetch("network_map_index_maps", expires_in: 6.hours) do
      featured.limit(200).filter(&:screenshot_exists?).map do |m|
        {
          id: m.id,
          screenshot: "/images/oligrapher/#{m.id}.png",
          url: m.url,
          title: m.name
        }
      end
    end
  end

  private

  def after_soft_delete
    UpdateEntityNetworkMapCollectionsJob
      .perform_later(id, remove: entities.pluck(:id))
  end

  def update_network_map_collection?
    (title != 'Untitled Map') && graph_data_changed?
  end

  def start_update_entity_network_map_collections_job
    UpdateEntityNetworkMapCollectionsJob
      .perform_later(id, remove: entities_removed_from_graph, add: entities.pluck(:id))
  end
end

# rubocop:enable Rails/SafeNavigation
