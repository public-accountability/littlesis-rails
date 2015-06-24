class MapAnnotation < ActiveRecord::Base
  include Bootsy::Container

  belongs_to :map, class_name: "NetworkMap", foreign_key: "map_id", inverse_of: :annotations

  before_create :set_order

  def set_order
    self.order = map.annotations.map(&:order).to_a.max.to_i + 1
  end

  def entity_ids
    highlighted_entity_ids.to_s.split(',')
  end

  def rel_ids
    highlighted_rel_ids.to_s.split(',')
  end

  def text_ids
    highlighted_text_ids.to_s.split(',')
  end

  def to_map_data
    data = JSON.parse(map.prepared_data)

    if entity_ids.count > 0
      data['entities'].each { |e| e['status'] = (entity_ids.include?(e['id'].to_s) ? 'highlighted' : 'faded') }
    end

    if rel_ids.count > 0
      data['rels'].each { |r| r['status'] = (rel_ids.include?(r['id'].to_s) ? 'highlighted' : 'faded') }
    end

    {
      id: "#{map.id}-#{id}",
      title: title,
      description: description,
      entities: data['entities'],
      rels: data['rels'],
      texts: data['texts']
    }
  end
end