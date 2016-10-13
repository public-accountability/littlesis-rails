class NyFiler < ActiveRecord::Base
  has_one :ny_filer_entity
  has_many :entities, :through => :ny_filer_entity
  has_many :ny_disclosures, foreign_key: "filer_id"

  def self.search_filers(name)
    NyFiler.search( name, :sql => { :include => :ny_filer_entity })
  end
  
  def is_matched?
    ny_filer_entity.present?
  end

end
