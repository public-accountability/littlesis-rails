# frozen_string_literal: true

##
# module for datatable server-side processing
#
module Datatable

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

    def initialize(params)
      %w[draw start length].each do |var|
        instance_variable_set "@#{var}", params.fetch(var).to_i
      end

      @columns = params.fetch('columns').map { |c| c.fetch('data') }
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
  # By default, it will use the default scope
  # for the model, but if the model has defined
  # a class method `datatable` it will that scope.
  class Response
    class_attribute :model, instance_writer: false
    class_attribute :scope, instance_writer: false

    attr_reader :json
    delegate :as_json, to: :json

    def self.for(klass)
      Class.new(self) do
        self.model = klass.to_s.constantize
        self.scope = model.respond_to?(:datatable) ? :datatable : :itself
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
      search_term = ThinkingSphinx::Query.escape(@request.search)
      search_result = model.search(search_term, page: page, per_page: @request.length)
      @search_filtered_count = search_result.total_entries
      search_result.map(&record_to_hash)
    end

    def records
      model
        .send(scope)
        .order('id desc')
        .limit(@request.length)
        .offset(@request.start)
        .select('id', *@request.columns)
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

    def record_to_hash
      ->(r) { r.slice(*@request.columns) }
    end
  end
end
