require 'rails_helper'

describe BusinessPerson, :external_link, :type => :model do
  it { is_expected.to have_db_column(:sec_cik) }
  create_or_update_external_link_test('business_person', 'person')
end
