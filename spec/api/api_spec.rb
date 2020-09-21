describe Api do
  describe 'api_base' do
    it 'returns meta hash by default' do
      expect(Api.send(:api_base, RspecHelpers::TestActiveRecord.new)).to eql Api::META_HASH
    end

    it 'returns empty hash if meta is false' do
      expect(Api.send(:api_base, RspecHelpers::TestActiveRecord.new, meta: false)).to eq({})
    end

    context 'when called with a paginatable_collection' do
      it 'returns meta hash with paginate info by default' do
        expect(Api).to receive(:paginatable_collection?).once.and_return(true)
        expect(Api).to receive(:paginate_meta).once.and_return(current_page: 1, total_pages: 10)

        expect(Api.send(:api_base, RspecHelpers::TestActiveRecord.new)['meta'])
          .to eql Api::META.merge(current_page: 1, total_pages: 10)
      end

      it 'returns meta hash with paginate info WITHOUT common metadat info' do
        expect(Api).to receive(:paginatable_collection?).once.and_return(true)
        expect(Api).to receive(:paginate_meta).once.and_return(current_page: 1, total_pages: 10)

        expect(Api.send(:api_base, RspecHelpers::TestActiveRecord.new, meta: false)['meta'])
          .to eql(current_page: 1, total_pages: 10)
      end
    end
  end
end
