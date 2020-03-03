# frozen_string_literal: true

class OligrapherLockService
  LOCK_DURATION = 10.minutes.freeze

  Lock = Struct.new(:user_id, :time)

  class Error < Exceptions::LittleSisError
  end

  def initialize(map:, current_user:)
    @map = map
    @current_user = current_user

    unless @map.oligrapher_version == 3
      raise Error, "map \##{@map.id} is not version 3"
    end

    unless @map.editors.include?(current_user.id)
      raise Error, "user #{@current_user.id} is not an editor of map #{@map.id}"
    end

    @lock = Rails.cache.fetch(cache_key)
  end

  # Note
  def as_json
    if locked?
      @lock.to_h.merge(locked: true,
                       username: User.find(@lock.user_id).username,
                       user_has_lock: user_has_lock?)
    else
      { locked: false }
    end
  end

  def lock
    lock! if user_can_lock?
    self
  end

  def lock!
    new_lock = Lock.new(@current_user.id, Time.current)
    Rails.cache.write(cache_key, new_lock, :expires_in => LOCK_DURATION)
    @lock = new_lock
    self
  end

  def locked?
    @lock.present? && @lock.time > LOCK_DURATION.ago
  end

  def user_has_lock?
    @lock.user_id == @current_user.id
  end

  def user_can_lock?
    !locked? || user_has_lock?
  end

  private

  def cache_key
    "oligrapher/#{@map.id}/lock"
  end
end
