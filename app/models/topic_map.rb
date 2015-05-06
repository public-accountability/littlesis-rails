class TopicMap < ActiveRecord::Base
  belongs_to :topic, inverse_of: :topic_maps
  belongs_to :map, class_name: 'NetworkMap', inverse_of: :topic_maps
end