require 'rails_helper'

describe ToolkitPage, type: :model do
  describe 'validations' do
    subject { ToolkitPage.new(name: "page_name") }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:name) }
    it { should belong_to(:last_user) }
  end
end
