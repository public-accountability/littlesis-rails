# frozen_string_literal: true

require 'rails_helper'

describe Stockbroker, type: :model do
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:crd_number).of_type(:integer) }
  it { is_expected.to belong_to(:entity) }
end
