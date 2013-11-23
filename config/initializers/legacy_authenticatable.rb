require 'devise/strategies/authenticatable'
require 'php_serialize'

class LegacyAuthenticatable < Warden::Strategies::Base
  def authenticate!
    user = user_from_legacy_cookie

    if user.nil?
      fail
    else
      success!(user)
    end
  end

  def self.legacy_cookie_data(cookies)
    # must have legacy cookie named LittleSis
    return nil if cookies[:LittleSis].nil?

    # LittleSis cookie value must be an existing session_id in the database
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT data FROM sessions WHERE session_id = ?", cookies[:LittleSis]])
    data = ActiveRecord::Base.connection.select_value(sql)
  end

  def user_from_legacy_cookie
    data = self.class.legacy_cookie_data(cookies)
    return nil if data.nil?

    # cookie must include "authenticated" boolean and a "user_id"
    return nil if data.match(/authenticated\|b:1/).nil?
    match = data.match(/s:7:"user_id";s:\d+:"(\d+)"/)
    return nil if match.nil? or match.length < 2

    # user_id must belong to an SfGuardUser, which must have an associated User
    id = match[1]
    gu = SfGuardUser.find(id)
    return nil if gu.nil?    

    gu.user
  end

  def self.recent_views_from_legacy_cookie(cookies)
    data = legacy_cookie_data(cookies)
    match = data.match(/"viewed_entity_ids";([^}]+\})/)
    return nil if match.nil? or match.length < 2

    PHP.unserialize(match[1])
  end
end 

module Devise
  module Models
    module LegacyAuthenticatable
    end
  end
end

Warden::Strategies.add(:legacy_authenticatable, LegacyAuthenticatable)