class TopicIndustry < ActiveRecord::Base
  belongs_to :topic, inverse_of: :topic_industries
  belongs_to :industry, inverse_of: :topic_industries
end