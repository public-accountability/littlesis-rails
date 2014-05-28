class NetworkMap < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :network_maps
  delegate :user, to: :sf_guard_user

  def prepared_data
    hash = JSON.parse(data)
    JSON.dump({ 
      entities: hash['entities'].map { |entity| self.prepare_entity(entity) },
      rels: hash['rels'].map { |rel| self.prepare_rel(rel) }
    })
  end

  def prepare_entity(entity)
    primary_ext = entity['primary_ext'].present? ? entity['primary_ext'] : (entity['url'].include?('person') ? 'Person' : 'Org')
    entity['primary_ext'] = primary_ext

    if entity['image'] and !entity['image'].include?('netmap') and !entity['image'].include?('anon')
      image_path = entity['image']
    elsif entity['filename']
      image_path = Image.image_path(entity['filename'], 'profile')
    else
      image_path = (primary_ext == 'Person' ? ActionController::Base.helpers.image_path('netmap-person.png') : ActionController::Base.helpers.image_path('netmap-org.png'))
    end

    url = ActionController::Base.helpers.url_for(Entity.legacy_url(entity['primary_ext'], entity['id'], entity['name'], 'map'))

    {
      id: self.class.integerize(entity['id']),
      name: entity['name'],
      image: image_path,
      url: url,
      description: (entity['blurb'] || entity['description']),
      x: entity['x'],
      y: entity['y'],
      fixed: true
    }
  end

  def prepare_rel(rel)
    url = ActionController::Base.helpers.url_for(Relationship.legacy_url(rel['id']))

    {
      id: self.class.integerize(rel['id']),
      entity1_id: self.class.integerize(rel['entity1_id']),
      entity2_id: self.class.integerize(rel['entity2_id']),
      category_id: self.class.integerize(rel['category_id']),
      category_ids: Array(self.class.integerize(rel['category_ids'])),
      is_current: self.class.integerize(rel['is_current']),
      end_date: rel['end_date'],
      value: 1,
      label: rel['label'],
      url: url,
      x1: rel['x1'],
      y1: rel['y1'],
      fixed: true
    }
  end

  def self.integerize(value)
    return nil if value.nil?
    return value.map { |elem| integerize(elem) } if value.instance_of?(Array)
    return integerize(value.split(',')) if value.instance_of?(String) and value.include?(',')
    return nil if value.to_i == 0 and value != "0"
    value.to_i
  end
end
