# frozen_string_literal: true

# This table is created from parsing our nginx logs.
# We use a custom nginx log format with these columns:
#  - remote address
#  - time
#  - host
#  - method
#  - uri
#  - status
#  - body_bytes_sent
#  - request_time
#  - http_referer
#  - http_user_agent
#  - request_id
class WebRequest < ApplicationRecord
  # We only keep ip addresses and user agents in our database for 1 week
  def self.nullify_identifying_data
    execute_sql <<~SQL
      UPDATE web_requests
      SET remote_address = NULL, user_agent = NULL
      WHERE remote_address IS NOT NULL AND `time` <= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
    SQL
  end
end
