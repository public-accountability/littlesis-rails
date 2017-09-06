class Tag < ActiveRecord::Base
  has_many :taggings

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true

  def restricted?
    restricted
  end

  # def tag.permissions
  #       fetch(:permissions)
  #     end

  # (set, set) -> hash
  def self.parse_update_actions(client_ids, server_ids)
    {
      ignore: client_ids & server_ids,
      add: client_ids - server_ids,
      remove: server_ids - client_ids
    }
  end
end

