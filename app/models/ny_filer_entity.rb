class NyFilerEntity < ActiveRecord::Base
  belongs_to :ny_filer
  belongs_to :entity
  
  validates_presence_of :ny_filer_id, :entity_id, :filer_id
end
