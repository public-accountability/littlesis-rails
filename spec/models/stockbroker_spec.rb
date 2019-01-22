# frozen_string_literal: true

require 'rails_helper'

describe Stockbroker, type: :model do
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:crd_number).of_type(:integer) }
  it { is_expected.to belong_to(:entity) }

  describe 'creating a stockbroker' do
    let(:crd_number) { rand(10_000) }

    it 'can be added to an org' do
      entity = create(:entity_org)
      expect { entity.add_extension('Stockbroker') }
        .to change(Stockbroker, :count).by(1)
    end

    it 'can be added to an person' do
      entity = create(:entity_person)
      expect { entity.add_extension('Stockbroker') }
        .to change(Stockbroker, :count).by(1)
    end

    it 'can have crd number' do
      entity = create(:entity_person)
      entity.add_extension('Stockbroker', crd_number: crd_number)
      expect(Stockbroker.last.crd_number).to eq crd_number
    end
  end
end
