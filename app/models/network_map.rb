# frozen_string_literal: true

class NetworkMap < ApplicationRecord
  include SingularTable
  include SoftDelete

  has_paper_trail on: [:update, :destroy]

  delegate :url_helpers, to: 'Rails.application.routes'

  # TODO: remove relience of sf_guard_user
  belongs_to :sf_guard_user, foreign_key: 'sf_user_id', inverse_of: :network_maps, optional: true
  belongs_to :user, foreign_key: 'sf_user_id', primary_key: 'sf_guard_user_id', inverse_of: :network_maps, optional: true

  # delegate :user, to: :sf_guard_user
  # before_create -> { self[:sf_user_id] = user_id }

  scope :featured, -> { where(is_featured: true) }
  scope :public_scope, -> { where(is_private: false) }
  scope :private_scope, -> { where(is_private: true) }
  scope :with_description, -> { where.not(description: [nil, '']) }
  scope :with_annotations, -> { where.not(annotations_data: '[]') }
  scope :without_annotations, -> { where(annotations_data: '[]') }

  validates :title, presence: true

  before_save :set_defaults, :set_index_data, :generate_secret
  before_save :start_update_entity_network_map_collections_job, if: :update_network_map_collection?

  def set_index_data
    self.index_data = generate_index_data
  end

  def generate_index_data
    entities_text = entities.pluck(:name, :blurb).flatten.compact.join(', ')
    if captions.present?
      captions_text = captions.map { |c| c['display']['text'] }.join(', ')
      "#{entities_text}, #{captions_text}"
    else
      entities_text
    end
  end

  def destroy
    soft_delete
  end

  def set_defaults
    self.data = default_data if data.blank?
    self.width = Lilsis::Application.config.netmap_default_width if width.blank?
    self.height = Lilsis::Application.config.netmap_default_width if height.blank?
    self.zoom = '1' if zoom.blank?
  end

  def generate_secret
    self.secret = SecureRandom.hex(10)
  end

  def cloneable?
    return false if is_private
    is_cloneable
  end

  def default_data
    JSON.dump({ entities: [], rels: [], texts: [] })
  end

  def prepared_objects
    d = (data or default_data)
    hash = JSON.parse(d)
    { 
      entities: hash['entities'].map { |entity| self.class.prepare_entity(entity) },
      rels: hash['rels'].map { |rel| self.class.prepare_rel(rel) },
      texts: hash['texts'].present? ? hash['texts'].map { |text| self.class.prepare_text(text) } : []
    }
  end

  def prepared_data
    json = JSON.dump(prepared_objects)
    ERB::Util.json_escape(json)
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

  def self.entity_type(entity)
    return entity['type'] if entity['type'].present?
    
    if entity['primary_ext'].present?
      return entity['primary_ext']
    else
      if entity['url'].present? and entity['url'].match(/person\/\d+\//)
        return 'Person'
      elsif entity['url'].present? and entity['url'].match(/org\/\d+\//)
        return 'Org'
      else
        return nil
      end
    end
  end

  def self.is_custom_entity?(entity)
    if entity['custom'].present?
      entity['custom']
    else
      entity['id'].to_s[0] == "x"
    end
  end

  def self.prepare_entity(entity)
    type = entity_type(entity)

    if entity['image'] and !entity['image'].include?('netmap') and !entity['image'].include?('anon')
      image_path = entity['image']
    elsif entity['filename']
      image_path = Image.image_path(entity['filename'], 'profile')
    else
      image_path = nil
    end

    if is_custom_entity?(entity)
      url = entity['url']
    else
      url = ActionController::Base.helpers.url_for(Entity.legacy_url(type, entity['id'], entity['name']))
    end

    {
      id: is_custom_entity?(entity) ? entity['id'] : self.integerize(entity['id']),
      name: entity['name'],
      image: image_path,
      url: url,
      description: (entity['blurb'] || entity['description']),
      x: entity['x'],
      y: entity['y'],
      fixed: true,
      type: type,
      hide_image: entity['hide_image'].present? ? entity['hide_image'] : false,
      custom: is_custom_entity?(entity),
      scale: entity['scale']
    }
  end

  def self.is_custom_rel?(rel)
    if rel['custom'].present?
      rel['custom']
    else
      rel['id'].to_s[0] == "x"
    end
  end

  def self.prepare_rel(rel)
    if is_custom_rel?(rel)
      url = rel['url']
    else
      url = url_helpers.relationship_url(id: rel['id'])
    end

    # backward compatibility for maps created before rels could have multiple categories
    cat_ids = rel['category_ids'].present? ? rel['category_ids'] : [rel['category_id']].compact

    {
      id: is_custom_rel?(rel) ? rel['id'] : self.integerize(rel['id']),
      entity1_id: rel['entity1_id'].to_s[0] == "x" ? rel['entity1_id'].to_s : self.integerize(rel['entity1_id']),
      entity2_id: rel['entity2_id'].to_s[0] == "x" ? rel['entity2_id'].to_s : self.integerize(rel['entity2_id']),
      category_id: self.integerize(rel['category_id']),
      category_ids: Array(self.integerize(cat_ids)),
      is_current: self.integerize(rel['is_current']),
      is_directional: rel['is_directional'],
      end_date: rel['end_date'],
      scale: rel['scale'],
      label: rel['label'],
      url: url,
      x1: rel['x1'],
      y1: rel['y1'],
      fixed: true,
      custom: is_custom_rel?(rel)
    }
  end

  def self.prepare_text(text)
    text
  end

  def self.integerize(value)
    return nil if value.nil?
    return value.map { |elem| integerize(elem) } if value.instance_of?(Array)
    return integerize(value.split(',')) if value.instance_of?(String) and value.include?(',')
    return nil if value.to_i == 0 and value != "0"
    value.to_i
  end

  def name
    return "Map #{id}" if title.blank?
    title
  end

  def to_param
    title.nil? ? id.to_s : "#{id}-#{title.parameterize}"
  end

  def share_text
    title.nil? ? "Network map #{id}" : "Map of #{title}"
  end

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

  def to_clean_hash
    data = prepared_objects
    map = {
      id: id,
      title: title,
      description: description,
      entities: data[:entities],
      rels: data[:rels],
      texts: data[:texts]
    }
  end

  def to_collection_data
    ary = annotations.present? ? annotations.sort_by(&:order).map(&:to_map_data) : [to_clean_hash]
    ary << references_to_map_data
    { 
      id: id,
      title: title,
      description: description,
      user: { name: user.username, url: user.legacy_url },
      date: updated_at.strftime("%B %-d, %Y"),
      maps: ary,
      sources: documents.map { |r| { title: r.name, url: r.url } }
    }
  end

  # def annotations_data 
  #   annotations.map { |a| Oligrapher.annotation_data(a) }
  # end

  def has_annotations
    annotations.count > 0
  end

  def documents_to_html
    documents.map { |d| "<div><a href=\"#{d.url}\">#{d.name}</a></div>"}.join("\n")
  end

  def references_to_map_data
    hash = to_clean_hash
    hash[:id] = "#{id}-sources"
    hash[:title] = "Source Links"
    hash[:description] = documents_to_html
    hash
  end

  %i[edge node].each do |graph_component|
    # -> Array[String]
    define_method("#{graph_component}_ids") do |data|
      JSON.parse(data)[graph_component.to_s.pluralize].keys
    end

    # -> Array[String]
    define_method("numeric_#{graph_component}_ids") do |data = nil|
      send("#{graph_component}_ids", data.nil? ? graph_data : data)
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
    hash = JSON.parse(graph_data)
    hash['captions'].values
  end

  def annotations_data_with_sources
    annotations = JSON.parse(annotations_data)

    if list_sources and documents.count > 0
      annotations.concat([{
        id: "sources",
        nodeIds: [],
        edgeIds: [],
        captionIds: [],
        header: "Sources",
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

  # input: <User> --> NetworkMap::ActiveRecord_Relation
  def self.scope_for_user(user)
    where_condition = <<~SQL
      `network_map`.`is_private` = 0
      OR (`network_map`.`is_private` = 1 AND `network_map`.`user_id` = ?)
    SQL
    where(where_condition, user.sf_guard_user_id)
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
