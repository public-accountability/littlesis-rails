class OsCategory < ActiveRecord::Base
  include SingularTable

  has_many :os_entity_categories, primary_key: "category_id", foreign_key: "category_id", inverse_of: :os_category
  has_many :entities, through: :os_entity_categories, inverse_of: :os_categories

  def ignore_me_in_view
    sector_name == 'Unknown' or category_id == 'Z9000'
  end

  def legacy_path
    "/industry/category/#{category_id}"
  end
  
end
