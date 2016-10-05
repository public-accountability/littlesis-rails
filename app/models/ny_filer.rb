class NyFiler < ActiveRecord::Base
  belongs_to :entity, inverse_of: :ny_filer
end
