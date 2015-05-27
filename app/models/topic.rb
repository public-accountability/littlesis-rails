class Topic < ActiveRecord::Base
  include Bootsy::Container
  include SoftDelete
  include Cacheable

  has_many :topic_lists, inverse_of: :topic
  has_many :lists, through: :topic_lists, inverse_of: :topics
  has_many :topic_maps, inverse_of: :topic
  has_many :maps, class_name: 'NetworkMap', through: :topic_maps, inverse_of: :topics
  has_many :topic_industries, inverse_of: :topic
  has_many :industries, through: :topic_industries, inverse_of: :topics
  belongs_to :default_list, class_name: 'List', inverse_of: :default_topic

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  after_create :create_default_list, :set_default_shortcuts

  def create_default_list
    list = List.create(
      name: "#{name} Topic List", 
      description: "Entities associated with the #{name} topic regardless whether they're on any other list associated with the topic.",
      is_admin: true
    )
    update(default_list_id: list.id)
  end

  def set_default_shortcuts
    unless shortcuts.present?
      update(shortcuts: 
        '<a href="#entities">People and Orgs</a><br>' + "\n" +
        '<a href="#lists">Lists</a><br>' + "\n" +
        '<a href="#maps">Maps</a><br>' + "\n" +
        '<a href="#industries">Industries</a>'
      )
    end
  end

  def to_param
    slug
  end
end