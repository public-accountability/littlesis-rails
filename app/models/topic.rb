class Topic < ActiveRecord::Base
  include SoftDelete
  include Cacheable

  has_many :topic_lists, inverse_of: :topic
  has_many :lists, through: :topic_lists, inverse_of: :topics

  scope :myall, -> { where("1=1") }

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  def to_param
    slug
  end
end