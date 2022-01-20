describe RegistrationsHelper, type: :helper do
  describe 'registrations_form_group' do
    it 'generate form group html' do
      expect(helper.registrations_form_group { 'test' })
        .to eq '<div class="row"><div class="col-sm-12 col-md-10 col-lg-8">test</div></div>'
    end
  end
end
