require 'rails_helper'

describe NyMatch, type: :model do

  # before(:all) do 
  #   Entity.skip_callback(:create, :after, :create_primary_ext)
  #   DatabaseCleaner.start
  # end
  
  # after(:all) do 
  #   Entity.set_callback(:create, :after, :create_primary_ext)
  #   DatabaseCleaner.clean
  # end
  
  it { should validate_presence_of(:ny_disclosure_id) }
  it { should validate_presence_of(:donor_id) }

end
