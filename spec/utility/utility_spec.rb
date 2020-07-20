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

  describe 'sh' do
    context 'with successful command' do
      specify { expect(Utility.sh('true')).to be true }
    end

    context 'with unsuccessful command' do
      specify do
        expect { Utility.sh('false') }
          .to raise_error(Utility::SubshellCommandError, 'false')
      end

      specify do
        expect { Utility.sh('false', fail_message: ':-(') }
          .to raise_error(Utility::SubshellCommandError, ':-(')
      end
    end
  end

  describe 'convert_file_to_utf8' do
    let(:file) do
      Tempfile.new('non_utf8_file').tap do |f|
        f.binmode
        # the letter 'A' followed by an invalid utf8 char
        f.write("\x41\xFF")
        f.rewind
      end
    end

    it 'converts file to utf8, removing invalid characters' do
      Utility.convert_file_to_utf8(file.path)
      expect(File.open(file.path).read).to eql 'A'
    end
  end

  describe 'yes_no_converter' do
    it 'converts Y to true' do
      expect(Utility.yes_no_converter('Y')).to eql(true)
    end

    it 'converts N to false' do
      expect(Utility.yes_no_converter('N ')).to eql(false)
    end

    it 'returns nil otherwise' do
      expect(Utility.yes_no_converter('0')).to be_nil
    end
  end

  describe 'one_zero_converter' do
    it 'converts 1 to true' do
      expect(Utility.one_zero_converter('1')).to eql(true)
    end
    it 'converts 0 to false' do
      expect(Utility.one_zero_converter('0 ')).to eql(false)
    end
    it 'returns nil otherwise' do
      expect(Utility.one_zero_converter('blah')).to be_nil
    end
  end
end
