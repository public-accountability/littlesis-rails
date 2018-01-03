class GroupRequest
  include ActiveModel::Validations

  attr_accessor :name, :description, :campaign
 
  validates_presence_of :name, :description

  def initialize(name, description, campaign=nil)
    @name, @description, @campaign = name, description, campaign
  end
end