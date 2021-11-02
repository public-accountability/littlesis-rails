# frozen_string_literal: true

require 'net/http'

# Save documents to the internet active
#
# In the future we could expand this class to
# also replace dead links in the database
class InternetArchive
  # Saves a url to the Internet Archive
  def self.save_url(url)
    return unless Rails.env.production?

    response = Net::HTTP.get_response(URI("https://web.archive.org/save/#{url}"))

    if response.is_a?(Net::HTTPRedirection)
      Rails.logger.info "Saved to internet archive: #{response['location']}"
    else
      Rails.logger.warn "Failed to submit URL #{url} to the Internet Archive"
    end
  end
end
