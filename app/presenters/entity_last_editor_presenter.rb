# frozen_string_literal: true

class EntityLastEditorPresenter < SimpleDelegator
  attr_reader :last_editor, :last_edited_at

  def last_edited_link
  end

  def initialize(*args)
    super(*args)
    @last_editor = find_last_editor
    freeze
  end

  # Ideally, all edits to an `Entity` would be in the `Versions` table
  # and we could delete the last_user_id column. Until that happens
  # some edits will only trigger a change to last_user_id and do not
  # create a new version. Others do create a version but don't correctly
  # update the last_user_id column. It's a mess.
  def find_last_editor
    if last_version.nil?
      @last_edited_at = updated_at
      return last_user.user
    end

    if updated_at > last_version.created_at.advance(minutes: 1)
      @last_edited_at = updated_at
      last_user.user
    else
      @last_edited_at = last_version.created_at
      user = User.find_by(id: last_version.whodunnit)
      return user.nil? ? User.system_user : user
    end
  end

  private

  def last_version
    return @_last_version if defined?(@_last_version)

    @_last_version = versions.reorder(id: :desc).limit(1)[0]
  end

  def updated_at_within_one_minute_of(time)
    updated_at.between?(time.advance(minutes: -1), time.advance(minutes: 1))
  end
end
