class Session < ActiveRecord::Base
  def self.clear_expired(seconds=nil)
    seconds ||= 14.days

    # session updated_at field always stored in UTC time zone
    datetime = DateTime.now.ago(seconds).in_time_zone('UTC').to_s(:db) 

    Session.where("updated_at < ?", datetime).destroy_all
  end
end