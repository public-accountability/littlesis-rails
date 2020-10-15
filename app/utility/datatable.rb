# frozen_string_literal: true

##
# TO BE REMOVED AFTER NYFILER DATASET
# IS TRANSFER TO EXTERNAL ENTITIES
##
# module for datatable server-side processing
# for entity matching tables

# In order for this to work you have do define a
# function `entity_matches` on the model

module Datatable
  include EntitiesHelper

  # Symbol, Hash -> Hash
  def self.json_for(model, params)
    Datatable::Response
      .for(model)
      .new(Datatable::Request.new(params))
      .json
  end

  # Process datatable params into an object
  # that can be used to query the database
  #
  # Example: Datatable::Request.new(params)
  #
  # see https://datatables.net/manual/server-side
  # for the documentation on the format of a datatables request
  class Request
    attr_reader :draw, :start, :length, :search, :columns

    # When a request arrives, columns are assumed to be fields
    # on the model unless they are in this set:
    INTERACTIVE_COLUMNS = %w[entity_matches match_buttons].to_set

    def initialize(params)
      %w[draw start length].each do |var|
        instance_variable_set "@#{var}", params.fetch(var).to_i
      end

      @columns = params
                   .fetch('columns')
                   .map { |c| c.fetch('data') }
                   .delete_if { |c| c.empty? || INTERACTIVE_COLUMNS.include?(c) }

      @search = params.dig('search', 'value').presence

      freeze
    end
  end

  # Generates datatables api response
  # Use `.for` to create new classes
  # for each model where a datatable
  # Example:
  #
  #   + Response.for(:NyFiler).new(request)
  #
  # By default, it will use the regular scope
  # for the model, but if the model has defined
  # a class method `datatable` it will that scope.
  class Response
    class_attribute :model, instance_writer: false
    class_attribute :scope, instance_writer: false
    class_attribute :with_conditions, instance_writer: false

    attr_reader :json
    delegate :as_json, to: :json

    WITH_CONDITIONS = {
      :NyFiler => { is_matched: false }
    }.freeze

    def self.for(klass)
      Class.new(self) do
        self.model = klass.to_s.constantize
        self.scope = model.respond_to?(:datatable) ? :datatable : :itself
        self.with_conditions = WITH_CONDITIONS.fetch(klass, {})
      end
    end

    def initialize(request)
      @request = request
      @json = create_json.freeze
      freeze
    end

    private

    def create_json
      {
        'draw' => @request.draw,
        'recordsTotal' => model_count,
        'data' => @request.search ? search_records : records,
        'recordsFiltered' => records_filtered_count
      }
    end

    def search_records
      page = (@request.start / @request.length) + 1
      search_term = LsSearch.escape(@request.search)
      search_result = model.search(search_term, page: page, per_page: @request.length, with: with_conditions)
      @search_filtered_count = search_result.total_entries
      search_result.map(&record_to_hash)
    end

    def records
      model
        .send(scope)
        .limit(@request.length)
        .offset(@request.start)
        .map(&record_to_hash)
    end

    def records_filtered_count
      if @request.search
        @search_filtered_count # set by search_records()
      else
        model_count
      end
    end

    def model_count
      return @_model_count if defined?(@_model_count)

      @_model_count = model.send(scope).count
    end

    def entity_match_format(entity)
      return '' if entity.nil?

      ApplicationController.helpers.link_to(entity.name, concretize_entity_url(entity))
    end

    def record_to_hash
      ->(r) do
        r.slice(*@request.columns)
          .merge('entity_matches' => entity_matches_for(r))
      end
    end

    # ActiveRecord --> [{}]
    def entity_matches_for(record)
      record.entity_matches.map do |evaluation_result|
        evaluation_result.entity.slice('id', 'name', 'primary_ext')
      end
    end
  end
end
