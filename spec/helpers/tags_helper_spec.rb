require 'rails_helper'

describe TagsHelper, type: :helper do

  describe '#tags_format_edit_event' do
    subject { helper.tags_format_edited_by(edit_event) }

    let(:username) { Faker::Internet.user_name }
    let(:mock_entity) do
      user = build(:user, username: username)
      build(:org).tap do |org|
        allow(org).to receive(:last_user).and_return(double(:user => user))
      end
    end

    context 'event is tag_added' do
      let(:edit_event) { { 'event' => 'tag_added', 'event_timestamp' => 1.day.ago } }
      it { is_expected.to eql "Edited 1 day ago" }
    end

    context 'tagable is a list' do
      let(:edit_event) do
        { 'event' => 'tagable_updated', 'event_timestamp' => 1.day.ago, 'tagable_class' => 'List' }
      end
      it { is_expected.to eql "Edited 1 day ago" }
    end

    context 'event is not tag_added and is an entity' do
      let(:edit_event) do
        {
          'event' => 'tagable_updated',
          'tagable_class' => 'Entity',
          'event_timestamp' => 1.day.ago,
          'tagable' => mock_entity
        }
      end
      it { is_expected.to eql "Edited 1 day ago by #{username}" }
    end
  end

  describe '#tags_format_edit_event' do
    subject { helper.tags_format_edit_event(edit_event) }
    context 'tag added event' do
      let(:edit_event) { { 'event' => 'tag_added' } }
      it { is_expected.to eql 'Tagged' }
    end

    context 'update event' do
      let(:edit_event) { { 'event' => 'tagable_updated', 'tagable_class' => 'List' } }
      it { is_expected.to eql 'List updated' }
    end
  end
end
