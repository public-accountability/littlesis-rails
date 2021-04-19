describe Page, type: :model do
  describe 'db columns' do
    [:name, :title, :last_user_id].each do |col|
      it { should have_db_column(col) }
    end
  end

  it { should belong_to(:last_user).optional }

  it 'responds to pagify_name' do
    expect(Page.respond_to?(:pagify_name)).to be true
  end
end
