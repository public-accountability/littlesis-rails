describe 'relationships/edit.html.erb', type: :view do
  let(:user) { build(:user) }

  def has_common_fields
    css 'label', text: 'Start date'
    css 'label', text: 'End date'
    css 'label', text: 'Is current'
    css 'input#relationship_start_date'
    css 'input#relationship_end_date'
    css 'input[name="relationship[is_current]"]', count: 3
    css 'label', text: 'Notes'
    css 'textarea[name="relationship[notes]"]', count: 1
  end

  describe 'Position Relationship' do
    let(:rel) do
      build(:relationship, category_id: 1, description1: 'boss', id: 123, updated_at: Time.current).tap do |rel|
        rel.position = build(:position, is_board: false)
        rel.last_user = user
      end
    end

    before do
      assign(:relationship, rel)
      render
    end

    it 'renders header partial' do
      expect(view).to render_template(partial: '_header', count: 1)
    end

    it 'renders references widget' do
      expect(view).to render_template(partial: 'shared/editing/_reference_widget', count: 1)
    end

    it 'has title' do
      css 'h1', text: 'Position: Human Being, mega corp LLC'
    end

    it 'has label: title' do
      css 'label', text: 'Title'
      not_css 'label', text: 'Type'
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has is board radio buttons' do
      css 'label', text: 'Board member'
      css 'input[name="relationship[position_attributes][is_board]"]', count: 3
    end

    it 'has is executive radio buttons' do
      css 'label', text: 'Executive'
      css 'input[name="relationship[position_attributes][is_executive]"]', count: 3
    end

    it 'has is employee radio buttons' do
      css 'label', text: 'Employee'
      css 'input[name="relationship[position_attributes][is_employee]"]', count: 3
    end

    it 'has compensation field' do
      css 'label', text: 'Compensation'
      css 'input[name="relationship[position_attributes][compensation]"]', count: 1
    end

    it 'has no error divs' do
      not_css 'div.alert'
    end
  end

  describe 'Donation relationship' do
    before do
      @rel = build(:relationship, category_id: 5, description1: 'donation', id: 123, updated_at: Time.now)
      @rel.donation = build :donation
      @rel.last_user = @user
      assign(:relationship, @rel)
      render
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has label: Type' do
      not_css 'label', text: 'Title'
      css 'label', text: 'Type'
    end

    it 'has amount' do
      css 'label', text: 'Amount'
      css 'input[name="relationship[amount]"]', count: 1
    end

    it 'has goods' do
      css 'label', text: 'Goods/services'
      css 'textarea[name="relationship[goods]"]', count: 1
    end

    it 'has no error divs' do
      not_css 'div.alert'
    end

    it 'has switch icon' do
      css 'span.bi-arrow-down-up', count: 1
    end
  end

  describe 'Education relationship' do
    before do
      rel = build(:relationship, category_id: 2, description1: 'Graduate', id: rand(100), updated_at: Time.current)
      rel.education = build :education
      rel.last_user = user
      assign(:relationship, rel)
      render
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has degree select' do
      css 'label', text: 'Degree'
      css 'select#relationship_education_attributes_degree_id', count: 1
    end

    it 'has field input' do
      css 'label', text: 'Field'
      css 'input[name="relationship[education_attributes][field]"]', count: 1
    end

    it 'has is_droput' do
      css 'label', text: 'Dropout'
      css 'input[name="relationship[education_attributes][is_dropout]"]', count: 3
    end

    it 'has no error divs' do
      not_css 'div.alert'
    end
  end

  describe 'Membership relationship' do
    before do
      rel = build(:relationship, category_id: 3, description1: 'member', id: rand(100), updated_at: Time.now)
      rel.membership = build :membership
      rel.last_user = user
      assign(:relationship, rel)
      render
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has dues field' do
      css 'label', text: 'Dues'
      css 'input[name="relationship[membership_attributes][dues]"]', count: 1
    end

    it 'does not have switch icon' do
      not_css 'span.bi-arrow-down-up'
    end
  end

  describe 'Transaction relationship' do
    before do
      rel = build(:relationship, category_id: 6, description1: 'buyer', updated_at: Time.current)
      rel.trans = build :transaction
      rel.last_user = user
      assign(:relationship, rel)
      render
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has description fields' do
      css 'div#description-fields'
    end

    it 'has switch icon' do
      css 'span.bi-arrow-down-up', count: 1
    end
  end

  describe 'Ownership relationship' do
    before do
      rel = build(:relationship, category_id: 10, description1: 'owner', updated_at: Time.current)
      rel.ownership = build :ownership
      rel.last_user = user
      assign(:relationship, rel)
      render
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has label: Description' do
      css 'label', text: 'Description'
    end

    it 'has percent stake' do
      css 'input[name="relationship[ownership_attributes][percent_stake]"]', count: 1
    end

    it 'has shares' do
      css 'input[name="relationship[ownership_attributes][shares]"]', count: 1
    end

    it 'has no error divs' do
      not_css 'div.alert'
    end

    it 'has switch icon' do
      css 'span.bi-arrow-down-up', count: 1
    end
  end

  describe 'hierarchy relationship' do
    before do
      rel = build(:relationship, category_id: 11, id: rand(100), updated_at: Time.current)
      rel.last_user = user
      assign(:relationship, rel)
      render
    end

    it 'has common fields' do
      has_common_fields
    end

    it 'has switch icon' do
      css 'span.bi-arrow-down-up', count: 1
    end
  end
end
