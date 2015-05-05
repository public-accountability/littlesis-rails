class Topic < ActiveRecord::Base
  include SoftDelete
  include Cacheable
end