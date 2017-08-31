module TaggingHelpers
  def creates_tags_and_tells_client_to_redirect
    it 'creates new tags' do
      expect(creating_list_tags).to change { List.find(list.id).tags.count }.by(2)
    end

    it 'redirects to edit list page' do
      creating_list_tags.call
      expect(response).to have_http_status :accepted
      expect(JSON.parse(response.body)['redirect']).to include edit_list_path(list)
    end
  end

  def denies_creating_tags_for_lists
    it 'does not create new tags' do
      expect(creating_list_tags).not_to change { List.find(list.id).tags.count }
    end

    it 'returns http status forbidden' do
      creating_list_tags.call
      expect(response).to have_http_status :forbidden
    end
  end
end
