describe ApplicationRecord do
  describe 'assign_attribute_unless_present' do
    let(:org) { build(:org) }

    it 'assigns new atribute' do
      expect(org.start_date).to be nil
      org.assign_attribute_unless_present :start_date, '1999-05-06'
      expect(org.start_date).to eq '1999-05-06'
    end

    it 'does not assigns new atribute' do
      org.start_date = '2000-00-00'
      expect(org.start_date).to eq '2000-00-00'
      org.assign_attribute_unless_present 'start_date', '2018-01-01'
      expect(org.start_date).to eql '2000-00-00'
    end

    it 'raises error if attribute does not exist' do
      expect { org.assign_attribute_unless_present('FOO', 'BAR') }
        .to raise_error(ActiveRecord::UnknownAttributeError)
    end
  end

  describe 'touch_by_current_user' do
    let(:user) { build(:user_with_id) }
    let(:org) { build(:org) }

    context 'Entity has current_user set' do
      it 'calls touch_by with current_user' do
        expect(org).to receive(:touch_by).with(user)
        org.current_user = user
        org.touch_by_current_user
      end
    end

    context 'Entity does not have current_user set' do
      it 'calls touch_by with system user' do
        expect(org).to receive(:touch_by).with(User.system_user_id)
        org.touch_by_current_user
      end
    end
  end

  describe 'touch_by' do
    let(:user) { create_really_basic_user }
    let(:new_user) { create_really_basic_user }
    let(:entity) do
      create(:entity_org, last_user_id: user.id)
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
          .to change(&entity_last_user_id).from(user.id).to(new_user.id)
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

  describe 'to_csv' do
    specify do
      expect(SwampTip.new(content: 'foo').to_csv).to eq [nil, 'foo', nil, nil].to_csv
    end
  end

  describe 'lookup_table_for' do
    let(:entities) { Array.new(2) { create(:entity_org) } }
    let(:entity_ids) { entities.map(&:id) }

    it 'turn a list of entity ids into a Hash from id to <Entity>' do
      expect(Entity.lookup_table_for(entity_ids))
        .to eql(entities[0].id => entities[0], entities[1].id => entities[1])
    end

    context 'when one entity has been deleted' do
      before { entities[0].soft_delete }

      it 'can optionally skips missing values' do
        expect(Entity.lookup_table_for(entity_ids, ignore: true))
          .to eql(entities[1].id => entities[1])
      end

      it 'raises error by default' do
        expect { Entity.lookup_table_for(entity_ids) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'execute_one' do
    specify do
      expect(ApplicationRecord.execute_one("SELECT 42")).to eql 42
    end
  end
end
