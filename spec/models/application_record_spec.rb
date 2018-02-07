require 'rails_helper'

describe ApplicationRecord do
  describe 'touch_by' do
    let(:user) { create_really_basic_user }
    let(:new_user) { create_really_basic_user }
    let(:entity) do
      create(:entity_org, last_user_id: user.sf_guard_user_id)
        .tap { |e| e.update_column(:updated_at, 10.years.ago) }
    end

    let(:tag) do
      create(:tag).tap { |t| t.update_column(:updated_at, 10.years.ago) }
    end

    let(:entity_updated_at_year) { proc { entity.reload.updated_at.year } }
    let(:entity_last_user_id) { proc { entity.reload.last_user_id } }
    let(:old_year) { 10.years.ago.year }
    let(:current_year) { Time.current.year }

    context 'model has a different last user id' do
      before { entity }

      it 'updates timestamp' do
        expect { entity.touch_by(new_user) }
          .to change(&entity_updated_at_year).from(old_year).to(current_year)
      end

      it 'updates last_user_id' do
        expect { entity.touch_by(new_user) }
          .to change(&entity_last_user_id).from(user.sf_guard_user_id).to(new_user.sf_guard_user_id)
      end
    end

    context 'model has the same last_user_id' do
      before { entity }

      it 'updates timestamp' do
        expect { entity.touch_by(user) }
          .to change(&entity_updated_at_year).from(old_year).to(current_year)
      end

      it 'does not update last_user_id' do
        expect { entity.touch_by(user) }.not_to change(&entity_last_user_id)
      end
    end

    context 'model does not have the attribute last_user_id' do
      it 'updates timestamp' do
        expect { tag.touch_by(new_user) }
          .to change { tag.reload.updated_at.year }
                .from(10.years.ago.year).to(Time.current.year)
      end
    end
  end

  describe 'lookup_table_for' do
    let(:entities) { Array.new(2) { create(:entity_org) } }
    let(:entity_ids) { entities.map(&:id) }

    it 'turn a list of entity ids into a Hash from id to <Entity>' do
      expect(Entity.lookup_table_for(entity_ids))
        .to eql(entities[0].id => entities[0], entities[1].id => entities[1])
    end
  end

  describe 'execute_one' do
    specify do
      expect(ApplicationRecord.execute_one("SELECT 42")).to eql 42
    end
  end
end
