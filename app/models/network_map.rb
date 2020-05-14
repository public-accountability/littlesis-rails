# frozen_string_literal: true

# rubocop:disable Rails/SafeNavigation

class NetworkMap < ApplicationRecord
  include SingularTable
  include SoftDelete

  LS_DATA_SOURCE_BASE_URL = "#{Rails.application.default_url_options[:protocol]}://#{Rails.application.default_url_options[:host]}"

  OLIGRAPHER_VERSION = APP_CONFIG['oligrapher_version']
  attribute :graph_data, OligrapherGraphData::Type.new
  serialize :editors, Array

  has_paper_trail on: [:update, :destroy]

  delegate :url_helpers, to: 'Rails.application.routes'

  belongs_to :user, foreign_key: 'user_id', inverse_of: :network_maps, optional: true

  scope :featured, -> { where(is_featured: true, oligrapher_version: 2) }
  scope :public_scope, -> { where(is_private: false, oligrapher_version: 2) }
  scope :private_scope, -> { where(is_private: true) }
  scope :with_description, -> { where.not(description: [nil, '']) }
  scope :with_annotations, -> { where.not(annotations_data: '[]') }
  scope :without_annotations, -> { where(annotations_data: '[]') }

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
    self.width = Lilsis::Application.config.netmap_default_width if width.blank?
    self.height = Lilsis::Application.config.netmap_default_width if height.blank?
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

  # TODO: store image locally instead of uploading to S3
  def generate_s3_thumb
    url = Rails.application.routes.url_helpers.embedded_map_url(self, :host => 'https://littlesis.org')

    local_path = "tmp/map-#{id}.png"
    s3_path = "images/maps/#{id}.png"

    # Screenshot is located in lib/screenshot.rb
    if Screenshot.take(url, local_path)
      Screenshot.resize_map_thumbnail(local_path)

      S3.upload_file remote_path: s3_path, local_path: local_path, check_first: false
      File.delete(local_path)
      self.thumbnail = S3.url('/' + s3_path)
      save
    else
      Rails.logger.debug "Failed to save screenshot for map #{id}"
    end
  end

  def documents_to_html
    documents.map { |d| "<div><a href=\"#{d.url}\">#{d.name}</a></div>"}.join("\n")
  end

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
      annotations.concat([{
        id: 'sources',
        nodeIds: [],
        edgeIds: [],
        captionIds: [],
        header: 'Sources',
        text: documents_to_html
      }])
    end

    JSON.dump(annotations)
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

  # Editor methods
  # These are only for oligrapher version 3
  def confirmed_editor_ids
    editors.filter { |e| !e.pending }.map(&:id)
  end

  def pending_editor_ids
    editors.filter { |e| e.pending }.map(&:id)
  end

  def all_editor_ids
    editors.map(&:id)
  end

  def add_editor(editor)
    editor_id = editor.try(:id) || editor.try!(:to_i)
    return self if all_editor_ids.include?(editor_id)

    if validate_editor(editor_id)
      editors << OpenStruct.new({ id: editor_id, pending: true })
      editors_will_change!
    end

    self
  end

  def remove_editor(editor)
    editor_id = editor.try(:id) || editor.try!(:to_i)

    unless user_id == editor_id
      self.editors.reject! { |e| e.id == editor_id }
      editors_will_change!
    end

    self
  end

  def confirm_editor(editor)
    editor_id = editor.try(:id) || editor.try!(:to_i)

    editors.map! { |e| e.id == editor_id ? OpenStruct.new(e.to_h.merge({ pending: false })) : e }

    self
  end

  def validate_editor(editor_id)
    if editor_id == user.id || User.exists?(id: editor_id)
      true
    else
      Rails.logger.info "[NetworkMap] Could not find editor #{editor_id} in the database"
      false
    end
  end

  def editor?(user)
    confirmed_editor_ids.include?(user.try(:id) || user.try!(:to_i))
  end

  def can_edit?(user)
    user.try(:to_i) == user_id || user.try(:id) == user_id || editor?(user)
  end

  def has_pending_editor?(user)
    pending_editor_ids.include?(user.id)
  end

  # input: <User> --> NetworkMap::ActiveRecord_Relation
  def self.scope_for_user(user)
    where arel_table[:is_private].eq(false)
            .or(arel_table[:user_id].eq(user.id))
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
