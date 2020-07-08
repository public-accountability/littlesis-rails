# frozen_string_literal: true

module NginxLogService
  FIELDS = %i[remote_address time host http_method uri status body_bytes request_time referer user_agent request_id].freeze

  def self.insert_file(path)
    File.foreach(path) do |line|
      request = FIELDS.zip(CSV.parse_line(line, col_sep: ' ')).to_h
      next if WebRequest.exists?(request_id: request[:request_id])

      WebRequest.create!(request)
    end
  end
end
