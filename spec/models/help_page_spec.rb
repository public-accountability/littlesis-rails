require 'rails_helper'

describe HelpPage, type: :model do
  it { should have_db_column(:name) }
  it { should have_db_column(:title) }
  it { should have_db_column(:markdown) }
  it { should have_db_column(:last_user_id) }
  it { should have_db_index(:name) }
end
