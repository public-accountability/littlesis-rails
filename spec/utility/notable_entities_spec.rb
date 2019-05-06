describe "NotableEntities" do
  specify { expect(NotableEntities).to be_a ActiveSupport::HashWithIndifferentAccess }
  specify { expect(NotableEntities.fetch(:senate)).to eq 12_885 }
  specify { expect(NotableEntities.fetch('democratic_party')).to eq 12_886 }
  specify { expect(NotableEntities.keys).to be_a Array }
  specify { expect(NotableEntities.frozen?).to be true }

  describe 'get' do
    it 'retrives Entity active record object' do
      expect(Entity).to receive(:find).with(12_884).once
      NotableEntities.get(:house_of_reps)
    end
  end
end
