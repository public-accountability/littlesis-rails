class Reference < ActiveRecord::Base
  include SingularTable
  has_paper_trail :on => [:update, :destroy]
  
  @@ref_types = {1=>"Generic", 2=>"FEC Filing", 3=>"Newspaper", 4=>"Government Document"}
  
  def ref_types
    @@ref_types
  end

  # Returns the reference types as an array: [ [name, number], ... ]
  # Removes the FEC filings option
  # Used by the add reference modal in _reference_new.html.erb
  def self.ref_type_options
    @@ref_types.to_a.map { |x| x.reverse }.delete_if { |x| x[1] == 2 }
  end

  def excerpt
    reference_excerpt.nil? ? nil : reference_excerpt.body
  end

  validates_presence_of :source, :object_id, :object_model
  has_one :os_match
  has_one :reference_excerpt
  has_one :os_donation, :through => :os_match
end
