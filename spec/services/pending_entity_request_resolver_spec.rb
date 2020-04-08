describe PendingEntityRequestResolver do
  let(:entity) { create(:entity_person) }
  let(:merge_request) { create(:merge_request, source: entity, status: 'pending') }
  let(:request_resolver) { PendingEntityRequestResolver.new(entity) }

  it 'closes merge request' do
    expect { request_resolver.run }
      .to change { merge_request.reload.status }
            .from('pending').to('denied')
  end
end
