# frozen_string_literal: true

# Subclassed by +EntityHistory+ and +ListHistory+
#
# at least two functions must be defined by the descendent:
#   versions and versions_sql
#
# Contains a few common utility functions to
# get information from Versions table
class RecordHistory
  include Pagination

  private_class_method def self.model_name(name)
    class_eval do
      const_set :MODEL_NAME, name
      attr_reader name
    end
  end

  def initialize(record)
    instance_variable_set "@#{self.class.const_get(:MODEL_NAME)}", record
  end

  def versions
    raise NotImplementedError    
  end

  protected

  def paginate_versions(page, per_page)
    paginate(page,
              per_page,
              versions_for(page: page, per_page: per_page),
              versions_count)
  end

  # int, int -> Array[Version]
  # returns PaperTrail::Version models, ordered by most recent
  def versions_for(page:, per_page:)
    PaperTrail::Version.find_by_sql(versions_paginated_sql(page: page, per_page: per_page))
  end

  # int, int -> str
  # paginated sql of versions query
  def versions_paginated_sql(page:, per_page:)
    "#{versions_sql} LIMIT #{per_page} OFFSET #{(page - 1) * per_page}"
  end

  def versions_count
    ApplicationRecord.execute_one versions_sql(select: 'COUNT(*)', order: '')
  end

  # This must be defined with two keyword arguments:
  #     - select
  #     - order
  def versions_sql
    raise NotImplementedError
  end
end
