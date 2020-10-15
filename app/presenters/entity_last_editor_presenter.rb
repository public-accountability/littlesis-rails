# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety

class EntityLastEditorPresenter < SimpleDelegator
  include EntitiesHelper

  attr_reader :last_editor, :last_edited_at, :html

  DIV_ID = 'entity-edited-history'

  delegate :content_tag, :link_to, :time_ago_in_words,
           to: 'ActionController::Base.helpers'

  delegate :user_page_path, to: 'Rails.application.routes.url_helpers'

  def initialize(*args)
    super(*args)
    @last_editor = find_last_editor
    @html = generate_html
    freeze
  end

  private

  def generate_html
    content_tag(:div, id: DIV_ID) do
      'Edited by '.html_safe +
        content_tag(:strong, link_to(@last_editor.username, user_page_path(@last_editor))) +
        " #{time_ago_in_words(@last_edited_at)} ago ".html_safe +
        link_to('History', concretize_edit_entity_path(__getobj__))
    end
  end

  # Ideally, all edits to an `Entity` would be in the `Versions` table
  # and we could delete the last_user_id column. Until that happens
  # some edits will only trigger a change to last_user_id and do not
  # create a new version. Others do create a version but don't correctly
  # update the last_user_id column. It's a mess.
  def find_last_editor
    if last_entity_edit.nil? || updated_at > last_entity_edit.created_at.advance(minutes: 1)
      @last_edited_at = updated_at
      User.system_user
    else
      @last_edited_at = last_entity_edit.created_at

      if last_entity_edit.user_id && last_entity_edit.user.present?
        last_entity_edit.user
      else
        User.system_user
      end
    end
  end

  def last_entity_edit
    return @_last_entity_edit if defined?(@_last_entity_edit)

    @_last_entity_edit = EditedEntity
                           .order(created_at: :desc)
                           .find_by(entity_id: id)
  end
end

# rubocop:enable Rails/OutputSafety
