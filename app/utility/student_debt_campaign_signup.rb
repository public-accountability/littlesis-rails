class StudentDebtCampaignSignup
  include ActiveModel::Validations

  attr_accessor :email, :first_name, :last_name, :school

  validates_presence_of :email, :first_name, :last_name, :school
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def self.from_params(params)
    signup = new

    params.each do |k, v|
      signup.instance_variable_set("@#{k}", v) unless v.nil?
    end

    signup
  end
end