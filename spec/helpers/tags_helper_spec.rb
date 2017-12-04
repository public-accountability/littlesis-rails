
require 'rails_helper'

describe TagsHelper, type: :helper do
  describe "#tags_edits_format_time" do
    it "displays the edit time in English" do
      edit_event = { 'event_timestamp' => 1.day.ago }
      expect(tags_edits_format_time(edit_event)).to eql "1 day ago"
    end
  end

  describe '#tags_edits_format_action' do
    subject { helper.tags_edits_format_action(edit_event) }
    context 'tag added event' do
      let(:edit_event) { { 'event' => 'tag_added', 'tagable_class' => 'Relationship' } }
      it { is_expected.to eql 'Relationship tagged' }
    end

    context 'update event' do
      let(:edit_event) { { 'event' => 'tagable_updated', 'tagable_class' => 'List' } }
      it { is_expected.to eql 'List updated' }
    end
  end

  describe '#tags_edits_format_editor' do
    subject { tags_edits_format_editor(edit_event) }

    context "when edited by a user" do
      let(:kropotkin){ build(:user, username: "Kropotkin") }
      let(:edit_event) { { "editor" => kropotkin } }

      it { is_expected.to eql link_to("Kropotkin", "/users/Kropotkin") }
    end

    context "when edited by The System" do
      let(:system) { User.find(APP_CONFIG["system_user_id"]) }
      let(:edit_event) { { "editor" => system } }

      it { is_expected.to eql "System" }
    end

    context "when editor is missing" do
      let(:edit_event) { {} }
      it { is_expected.to eql "System" }
    end
  end
end
