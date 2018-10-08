require 'rails_helper'

describe EntityMatchTable do
  describe 'initialize' do
    subject { EntityMatchTable.new(:NyFiler) }

    assert_attribute :model_type, 'NyFiler'
    assert_attribute :model, NyFiler
    assert_instance_var :page, 1
    assert_instance_var :per_page,  20
    assert_instance_var :scope, :datatable

    it 'raises error if called with model that is not permitted' do
      expect { EntityMatchTable.new(:Relationship) } .to raise_error(ArgumentError)
    end
  end

  describe 'headers' do
    subject { EntityMatchTable.new(:NyFiler).headers }

    it { is_expected.to eq ['Name', 'Filer ID', 'Matched Entity'] }
  end
end
