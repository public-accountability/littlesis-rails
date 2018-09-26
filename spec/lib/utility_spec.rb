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

end
