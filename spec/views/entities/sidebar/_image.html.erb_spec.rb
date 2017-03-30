require "rails_helper"

describe "partial: sidebar/image" do
  before { assign(:entity, build_stubbed(:org)) }

  it "contains a link and an img when the user is sign-in" do
    expect(view).to receive(:user_signed_in?).and_return(true)
    render partial: 'entities/sidebar/image.html.erb'
    css 'a', count: 1
    css 'img', count: 1
  end

  it 'does not contain a link when user is not signed in' do
    expect(view).to receive(:user_signed_in?).and_return(false)
    render partial: 'entities/sidebar/image.html.erb'
    not_css 'a'
    css 'img', count: 1
  end
end
