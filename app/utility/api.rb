# frozen_string_literal: true

module Api
  META = {
    'copyright' => 'LittleSis CC BY-SA 4.0',
    'license' => 'https://creativecommons.org/licenses/by-sa/4.0/us/',
    'apiVersion' => '2.0'
  }.freeze

  META_HASH = { 'meta' => META }.freeze

  ERROR_RESPONSES = {
    RECORD_NOT_FOUND: { title: 'Record Missing' },
    RECORD_DELETED: { title: 'Record Deleted' },
    INVALID_RELATIONSHIP_CATEGORY: { title: 'Invalid Relationship Category: only numbers 1-12 are permitted' }
  }.freeze

  LINKABLE_CLASSES = %i[entity relationship list].freeze

  # symbol -> hash
  # Accepted symbols:
  #  - RECORD_NOT_FOUND
  #  - RECORD_DELETED
  #  - INVALID_RELATIONSHIP_CATEGORY
  def self.error_json(err)
    {
      errors: Array.wrap(ERROR_RESPONSES.fetch(err)),
      meta: META
    }
  end

  def self.as_api_json(models, meta: true)
    api_base(models, meta: meta).deep_merge('data' => models.map(&:api_data))
  end

  private_class_method def self.api_base(models, meta: true)
    if paginatable_collection?(models)
      { 'meta' => paginate_meta(models).merge(meta ? META : {}) }
    else
      meta ? META_HASH : {}
    end
  end

  private_class_method def self.paginate_meta(models)
    { :currentPage => models.current_page, :pageCount => models.total_pages }
  end

  private_class_method def self.paginatable_collection?(collection)
    collection.respond_to?(:current_page) && collection.respond_to?(:total_pages)
  end
end
