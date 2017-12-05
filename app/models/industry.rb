class Industry < ActiveRecord::Base
  has_many :os_categories, primary_key: 'industry_id', foreign_key: 'industry_id'
  has_many :entities, through: :os_categories

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
