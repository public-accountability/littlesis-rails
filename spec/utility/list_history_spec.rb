describe ListHistory do
  with_versioning do
    context 'creating a list, adding an entity, and updated the name' do
      let(:user) { create_really_basic_user }
      before do
        PaperTrail.request(whodunnit: user.id.to_s) do
          @list = create(:list)
          ListEntity.create!(list: @list, entity: create(:entity_person))
          @list.update!(name: Faker::Lorem.sentence)
        end
      end
      subject { ListHistory.new(@list).versions }

      it 'contains 4 versions' do
        expect(subject.length).to be 4
      end

      it 'versions contain reference to the list' do
        subject.each { |v| expect(v.list).to eql @list }
      end

      it 'versions contain user' do
        subject.each { |v| expect(v.user).to eql user }
      end
    end
  end
end
