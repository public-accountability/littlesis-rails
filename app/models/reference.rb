class Reference < ActiveRecord::Base
  include SingularTable
  has_paper_trail :on => [:update, :destroy]
  
  @@ref_types = {1=>"Generic", 2=>"FEC Filing", 3=>"Newspaper", 4=>"Government Document"}
  
  def ref_types
    @@ref_types
  end

  validates_presence_of :source, :object_id, :object_model
  has_one :os_match
  has_one :os_donation, :through => :os_match
end
