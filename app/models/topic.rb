class Topic < ActiveRecord::Base
  include SoftDelete
  include Cacheable

  has_many :topic_lists, inverse_of: :topic
  has_many :lists, through: :topic_lists, inverse_of: :topics
  has_many :topic_maps, inverse_of: :topic
  has_many :maps, class_name: 'NetworkMap', through: :topic_maps, inverse_of: :topics

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  SOFT_DELETE_DEPENDENTS = [ :lists, :network_maps ]

  def to_param
    slug
  end
end