require 'rails_helper'

describe Utility do

  describe 'save_hash_array_to_csv' do
    let(:csv_file) { Tempfile.new }
    let(:hash_array) do
      [{ name: 'Alice', type: 'Cat' }, { name: 'Hedgy', type: 'Hedgehog' }]
    end

    it 'turns array into csv and saves contents to a file' do
      Utility.save_hash_array_to_csv(csv_file.path, hash_array)
      expect(csv_file.read).to eql "name,type\nAlice,Cat\nHedgy,Hedgehog\n"
    end
  end

  describe 'execute_sql_file' do
    let(:sql_file) do
      Tempfile.new.tap do |t|
        t.write sql
        t.rewind
      end
    end

    context 'with valid sql' do
      let(:sql) { 'select now()' }

      it 'runs command without error' do
        expect { Utility.execute_sql_file(sql_file.path) }.not_to raise_error
      end
    end

    context 'with invalid sql' do
      let(:sql) { 'Do I look like SQL to you?' }

      it 'raises an error' do
        expect { Utility.execute_sql_file(sql_file.path) }
          .to raise_error(Utility::SQLFileError)
      end
    end
  end

  describe 'file_is_empty_or_nonexistent' do
    context 'with empty file' do
      let(:empty_file) { Tempfile.new }

      specify do
        expect(Utility.file_is_empty_or_nonexistent(empty_file.path))
          .to be true
      end
    end

    context 'with nonexistent file' do
      let(:file_path) { '/tmp/this_file_does_not_exists.fake' }

      specify do
        expect(Utility.file_is_empty_or_nonexistent(file_path))
          .to be true
      end
    end

    context 'with a file with contents' do
      let(:file) do
        Tempfile.new.tap do |t|
          t.write 'abc'
          t.rewind
        end
      end

      specify do
        expect(Utility.file_is_empty_or_nonexistent(file.path))
          .to be false
      end
    end
  end

end
