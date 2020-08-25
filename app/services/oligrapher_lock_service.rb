# frozen_string_literal: true

class OligrapherLockService
  LOCK_DURATION = 5.minutes.freeze

  Lock = Struct.new(:user_id, :time)

  class Error < Exceptions::LittleSisError
  end

  def initialize(map:, current_user:)
    @map = map
    @current_user = current_user
    @permission_denied = true

    unless @map.oligrapher_version == 3
      raise Error, "map \##{@map.id} is not version 3"
    end

    if @map.can_edit?(@current_user)
      @permission_denied = false
    end

    fetch_lock
  end

  def fetch_lock
    @lock = Rails.cache.fetch(cache_key)
    self
  end

  def as_json
    return self.class.permission_error_json unless user_has_permission?

    if locked?
      @lock.to_h.merge(
        locked: true,
        name: User.find(@lock.user_id).username,
        user_has_lock: user_has_lock?
      )
    else
      { locked: false }
    end
  end

  def lock
    lock! if user_can_lock?
    self
  end

  def lock!
    return self unless user_has_permission?

    new_lock = Lock.new(@current_user.id, Time.current)
    Rails.cache.write(cache_key, new_lock, :expires_in => LOCK_DURATION)
    @lock = new_lock
    self
  end

  def release!
    if user_has_lock?
      Rails.cache.delete(cache_key)
      fetch_lock
    end

    self
  end

  def locked?
    @lock.present? && @lock.time > LOCK_DURATION.ago
  end

  def user_has_lock?
    @lock.present? && @lock.user_id == @current_user.id
  end

  def user_can_lock?
    user_has_permission? && (!locked? || user_has_lock?)
  end

  def user_has_permission?
    !@permission_denied
  end

  def self.permission_error_json
    { permission_denied: true }
  end

  private

  def cache_key
    "oligrapher/#{@map.id}/lock"
  end
end
