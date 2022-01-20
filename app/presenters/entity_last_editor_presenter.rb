# frozen_string_literal: true

class EntityLastEditorPresenter
  include EntitiesHelper

  attr_reader :last_editor, :last_edited_at, :html

  DIV_ID = 'entity-edited-history'

  # &#8505;
  HISTORY_ICON = '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" class="bi bi-clock-history entity-history-page-link" viewBox="0 0 16 16"><path d="M8.515 1.019A7 7 0 0 0 8 1V0a8 8 0 0 1 .589.022l-.074.997zm2.004.45a7.003 7.003 0 0 0-.985-.299l.219-.976c.383.086.76.2 1.126.342l-.36.933zm1.37.71a7.01 7.01 0 0 0-.439-.27l.493-.87a8.025 8.025 0 0 1 .979.654l-.615.789a6.996 6.996 0 0 0-.418-.302zm1.834 1.79a6.99 6.99 0 0 0-.653-.796l.724-.69c.27.285.52.59.747.91l-.818.576zm.744 1.352a7.08 7.08 0 0 0-.214-.468l.893-.45a7.976 7.976 0 0 1 .45 1.088l-.95.313a7.023 7.023 0 0 0-.179-.483zm.53 2.507a6.991 6.991 0 0 0-.1-1.025l.985-.17c.067.386.106.778.116 1.17l-1 .025zm-.131 1.538c.033-.17.06-.339.081-.51l.993.123a7.957 7.957 0 0 1-.23 1.155l-.964-.267c.046-.165.086-.332.12-.501zm-.952 2.379c.184-.29.346-.594.486-.908l.914.405c-.16.36-.345.706-.555 1.038l-.845-.535zm-.964 1.205c.122-.122.239-.248.35-.378l.758.653a8.073 8.073 0 0 1-.401.432l-.707-.707z"/><path d="M8 1a7 7 0 1 0 4.95 11.95l.707.707A8.001 8.001 0 1 1 8 0v1z"/><path d="M7.5 3a.5.5 0 0 1 .5.5v5.21l3.248 1.856a.5.5 0 0 1-.496.868l-3.5-2A.5.5 0 0 1 7 9V3.5a.5.5 0 0 1 .5-.5z"/></svg>'.freeze

  delegate :content_tag, :link_to, :time_ago_in_words,
           to: 'ActionController::Base.helpers'

  delegate :user_page_path, to: 'Rails.application.routes.url_helpers'

  def self.html(entity, user_signed_in)
    new(entity, user_signed_in: user_signed_in).html
  end

  def initialize(entity, user_signed_in: false)
    @entity = entity
    @last_editor = find_last_editor
    @html = if user_signed_in
              signed_in_html
            else
              public_html
            end
    freeze
  end

  private

  def public_html
    content_tag(:em) do
      content_tag(:span, updated_at)
    end
  end

  def signed_in_html
    content_tag(:em) do
      content_tag(:span, updated_at, title: "edited by #{@last_editor.username}")
    end + history_link
  end

  def updated_at
    "Updated #{time_ago_in_words(@last_edited_at)} ago"
  end

  def history_link
    content_tag(:span, class: 'ps-1') { link_to "#{HISTORY_ICON}".html_safe, concretize_history_entity_path(@entity) }
  end

  def generate_html_old
    content_tag(:div, id: DIV_ID) do
      'Edited by '.html_safe +
        content_tag(:strong, link_to(@last_editor.username, user_page_path(@last_editor))) +
        " #{time_ago_in_words(@last_edited_at)} ago ".html_safe +
        link_to('History', concretize_history_entity_path(@entity))
    end
  end

  # Ideally, all edits to an `Entity` would be in the `Versions` table
  # and we could delete the last_user_id column. Until that happens
  # some edits will only trigger a change to last_user_id and do not
  # create a new version. Others do create a version but don't correctly
  # update the last_user_id column. It's a mess.
  def find_last_editor
    if last_entity_edit.nil? || @entity.updated_at > last_entity_edit.created_at.advance(minutes: 1)
      @last_edited_at = @entity.updated_at
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
                           .find_by(entity_id: @entity.id)
  end
end
