class NyFiler < ActiveRecord::Base
  has_many :ny_filer_entities
  has_many :entities, :through => :ny_filer_entities
end
