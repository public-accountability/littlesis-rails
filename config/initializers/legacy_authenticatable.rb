require 'devise/strategies/authenticatable'
require 'php_serialize' 

class LegacyAuthenticatable < Warden::Strategies::Base
  def authenticate!
    fail if cookies[:LittleSis].nil?

    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT data FROM sessions WHERE session_id = ?", cookies[:LittleSis]])
    data = ActiveRecord::Base.connection.select_value(sql)

    fail if data.nil?

    match = data.match(/s:7:"user_id";s:\d+:"(\d+)"/)

    fail if match.length < 2

    id = match[1]
    gu = SfGuardUser.find(id)

    fail if gu.nil?
    fail if gu.user.nil?

    success!(gu.user)
  end
end 

module Devise
  module Models
    module LegacyAuthenticatable
    end
  end
end

Warden::Strategies.add(:legacy_authenticatable, LegacyAuthenticatable)