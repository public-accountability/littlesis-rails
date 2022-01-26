describe 'lists/edit.html.erb', type: :view do
  before(:each) do
    allow(controller).to receive(:current_user)
                          .and_return(double(:admin? => false,
                                             :permissions => double(:tag_permissions => {})))

    assign(:list, build(:list))
    render template: "lists/edit"
  end

  it 'contains form' do
    css 'form'
  end

  it { is_expected.to render_template("lists/_settings") }
  it { is_expected.to render_template("lists/_settings_admin") }
  it { is_expected.to render_template("lists/_edit_tags") }
end
