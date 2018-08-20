require 'rails_helper'

describe 'SoftDelete' do
  before(:all) do
    ApplicationRecord.connection.execute('DROP TABLE IF EXISTS test_records')
    ApplicationRecord.connection.create_table 'test_records' do |t|
      t.string 'name'
      t.boolean 'is_deleted', default: false, null: false
      t.timestamps
    end
  end

  after(:all) do
    ApplicationRecord.connection.execute('DROP TABLE IF EXISTS test_records')
  end

  before(:each) do
    stub_const 'TestRecord', Class.new(ApplicationRecord)
    TestRecord.class_eval { include SoftDelete } 
  end

  describe 'default scope' do
    before do
      TestRecord.create!
      TestRecord.create!(is_deleted: true)
    end

    it 'hides deleted records' do
      expect(TestRecord.count).to eql 1
      expect(TestRecord.unscoped.count).to eql 2
    end
  end

  describe 'Callbacks' do
    before do
      TestRecord.class_eval do
        before_soft_delete :abc
        def abc; end
      end
    end

    it 'defines callback class methods' do
      %i[before_soft_delete after_soft_delete around_soft_delete].each do |method|
        expect(TestRecord).to respond_to method
      end
    end

    it 'allows callbacks to be set' do
      test_record = TestRecord.new
      expect(test_record).to receive(:abc).once
      test_record.soft_delete
    end
  end

  describe 'two ways to set after soft delete' do
    context 'errors with implemented method "after_soft_delete"' do
      before do
        TestRecord.class_eval do
          def after_soft_delete
            raise ActiveRecord::RecordNotFound
          end
        end
      end

      it 'raises error and does not change deleted status' do
        test_record = TestRecord.create!(is_deleted: false)

        expect { test_record.soft_delete }.to raise_error(ActiveRecord::RecordNotFound)
        expect(test_record.reload.is_deleted).to eql false
      end
    end

    context 'errors with after callabck"' do
      before do
        TestRecord.class_eval do
          before_soft_delete :abc

          def abc
            raise ActiveRecord::RecordNotFound
          end
        end
      end

      it 'raises error and but is_deleted is still changed status' do
        test_record = TestRecord.create!(is_deleted: false)
        expect { test_record.soft_delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
