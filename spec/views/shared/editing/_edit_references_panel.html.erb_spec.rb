describe 'shared/editing/_edit_references_panel.html.erb', type: :view do
  let(:references) { Array.new(2) { build(:reference) } }
  let(:selected_ref) { nil }
  let(:locals) { { references: references, selected_ref: selected_ref } }
  let(:partial_render) do
    render partial: 'shared/editing/edit_references_panel', locals: locals
  end

  context 'without a selected_ref' do
    it 'contains divs' do
      partial_render
      css '#edit-references-panel'
      css '#existing-sources-container'
      css '#new-reference-form'
    end

    it 'calls references_select with correct fields' do
      expect(view).to receive(:references_select).with(references, nil).once
      partial_render
    end
  end

  context 'with a selected_ref' do
    let(:selected_ref) { references.first.id }

    it 'calls references_select with correct fields' do
      expect(view).to receive(:references_select).with(references, references.first.id).once
      partial_render
    end
  end
end
