require 'rails_helper'

RSpec.describe Image, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:entity_id) }
    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:title) }
  end

  describe 'soft_delete' do
    it 'changes is_deleted' do
      image = create(:image, entity: create(:org))
      expect { image.soft_delete }.to change { image.is_deleted }.to(true)
    end
  end
end
