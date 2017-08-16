module ListHelpersForExampleGroups
  def test_request_for_user(x)
    it "is #{x[:response]} for #{x[:action]} by #{x[:user]}" do
      sign_in instance_variable_get(x[:user]) if x[:user].present?
      get x[:action], id: '123'
      expect(response).to have_http_status(x[:response])
      sign_out instance_variable_get(x[:user]) if x[:user].present?
    end
  end  
end
