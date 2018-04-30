# frozen_string_literal: true

# Subclassed by +EntityHistory+ and +ListHistory+
#
#
# Contains a few common utility functions to
# get information from Versions table
class RecordHistory
  PER_PAGE = 15
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

  # int, int -> Kaminari::PaginatableArray
  # Returns paginated array of versions
  # Each version has an extra attribute -- user -- with the User model
  # of the user responsible for the change
  def versions(page: 1, per_page: nil)
    per_page = self.class.const_get(:PER_PAGE) if per_page.nil?
    define_as_presenters(
      add_users_to_versions(
        paginate_versions(page, per_page)
      )
    )
  end

  protected

  # This must be defined with two keyword arguments:
  #     - select
  #     - order
  def versions_sql
    raise NotImplementedError
  end

  private

  def paginate_versions(page, per_page)
    paginate(page,
             per_page,
             versions_for(page: page, per_page: per_page),
             versions_count)
  end

  # add singleton method `as_presenters` which converts each Version to EntityVersionPresenter
  def define_as_presenters(versions)
    presenter_class = "#{self.class.const_get(:MODEL_NAME).to_s.capitalize}VersionPresenter".constantize
    versions.tap do |vrs|
      vrs.define_singleton_method(:as_presenters) do
        map { |v| presenter_class.new(v) }
      end
    end
  end

  # [Array-like] -> [Array-like]
  # add attribute user to each <Version> which the <User> model
  # adds record attribute to each version
  #   for instance, if model_name is "entity"
  #   each version will have the attribute 'entity' with the
  #   record this class was initialized with
  def add_users_to_versions(versions)
    users = User.lookup_table_for versions.map(&:whodunnit).compact.uniq
    model_name = self.class.const_get(:MODEL_NAME)
    model_for = send(model_name)

    versions.map do |version|
      version.tap do |v|
        v.singleton_class.class_exec do
          attr_reader :user
          attr_reader model_name
        end
        v.instance_exec do
          @user = users.fetch(v.whodunnit.to_i, nil)
          instance_variable_set "@#{model_name}", model_for
        end
      end
    end
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
end
