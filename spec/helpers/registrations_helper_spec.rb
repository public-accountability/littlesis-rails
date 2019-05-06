describe RegistrationsHelper, type: :helper do
  describe 'registrations_form_group' do
    it 'generate form group html' do
      expect(helper.registrations_form_group { 'test' })
        .to eql '<div class="form-group row"><div class="col-6">test</div></div>'
    end
  end
end
