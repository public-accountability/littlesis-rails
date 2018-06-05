require 'rails_helper'

describe BusinessPerson do
  it { is_expected.to have_db_column(:sec_cik) }
end
