# frozen_string_literal: true

require 'net/http'

# Save documents to the internet active
#
# In the future we could expand this class to
# also replace dead links in the database
class InternetArchive
  HEADERS = { 'Accept' => 'application/json' }.freeze

  # Saves a url to the Internet Archive
  def self.save_url(url)
    Net::HTTP.start('web.archive.org', 443, use_ssl: true) do |http|
      request = Net::HTTP::Get.new("/save/#{url}", HEADERS)
      http.request(request)
    end
  rescue
    Rails.logger.warn "Failed to submit URL #{url} to the Internet Archive"
  end
end
