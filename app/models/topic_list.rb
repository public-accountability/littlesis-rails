class TopicList < ActiveRecord::Base
  belongs_to :topic, inverse_of: :topic_lists
  belongs_to :list, inverse_of: :topic_lists
end