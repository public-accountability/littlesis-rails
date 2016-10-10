class NyFiler < ActiveRecord::Base
  has_many :entity, :through => :ny_filer_entities
end
