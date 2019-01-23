require 'rails_helper'

describe BusinessPerson, :external_link, :type => :model do
  it { is_expected.to have_db_column(:sec_cik) }
  it { is_expected.to have_db_column(:crd_number).of_type(:integer) }
  create_or_update_external_link_test('business_person', 'person')
end
