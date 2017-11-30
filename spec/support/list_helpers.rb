module ListHelpersForExampleGroups
  def test_request_for_user(x)
    it "is #{x[:response]} for #{x[:action]} by #{x[:user]}" do
      sign_in instance_variable_get(x[:user]) if x[:user].present?
      if x[:action] == :update
        patch x[:action], { id: '123', list: {name: 'list name'} }
      elsif x[:action] == :destroy
        delete x[:action], id: '123'
      elsif [:add_entity, :remove_entity, :update_entity].include?(x[:action])
        post x[:action], {id: '123', entity_id: '123', list_entity_id: '456' }
      elsif x[:action] == :create_entity_associations
        post x[:action]#, { data: [{ type: 'entities', id: 1 }] }
      else
        get x[:action], id: '123'
      end
      expect(response).to have_http_status(x[:response])
      sign_out instance_variable_get(x[:user]) if x[:user].present?
    end
  end  
end
