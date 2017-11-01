module Api
  META = {
    copyright: 'LittleSis CC BY-SA 3.0',
    license: 'https://creativecommons.org/licenses/by-sa/3.0/us/',
    apiVersion: '2.0-beta'
  }.freeze

  META_HASH = { 'meta' => META }.freeze

  ERROR_RESPONSES = {
    RECORD_NOT_FOUND: { title: 'Record Missing' },
    RECORD_DELETED: { title: 'Record Deleted' }
  }

  # symbol -> hash
    # Accepted symbols:
    #  - RECORD_NOT_FOUND
    #  - RECORD_DELETED
  def self.error_json(err)
    {
      errors: Array.wrap(ERROR_RESPONSES.fetch(err)),
      meta: META
    }
  end

  def self.as_api_json(models)
    api_base(models).deep_merge('data' => models.map(&:api_data))
  end

  private_class_method def self.api_base(models)
    if models.is_a? ThinkingSphinx::Search
      META_HASH.deep_merge('meta' => { :currentPage => models.current_page, :pageCount => models.total_pages })
    else
      META_HASH
    end
  end
end
