# frozen_string_literal: true

##
# module for datatable server-side processing
#
module Datatable
  # Process datatable params into an object
  # that can be used to query the database
  #
  # Example: Datatable::Request.new(params)
  #
  # see https://datatables.net/manual/server-side
  # for the documentation on the format of a datatables request
  class Request
    attr_reader :draw, :start, :length, :search

    def initialize(params)
      %w[draw start length].each do |var|
        instance_variable_set "@#{var}", params.fetch(var).to_i
      end

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
  class Response
    class_attribute :model
    attr_reader :json
    define_method(:as_json) { @json }

    def self.for(klass)
      Class.new(self) do
        self.model = klass.to_s.constantize
      end
    end

    def initalize(request)
      @model = self.class.model
      @request = request
      @json = create_json
      freeze
    end

    private

    def create_json
      # @total_records = @model.count
      # @model.limit(request.limit).offset(request.offset)
      # {
      #   draw: @request.draw,
      # }
    end
  end
end
