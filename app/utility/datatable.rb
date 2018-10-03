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
  class Response
    class_attribute :model, instance_writer: false
    attr_reader :json

    delegate :as_json, to: :json

    def self.for(klass)
      Class.new(self) do
        self.model = klass.to_s.constantize
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
        'recordsTotal' => model.count,
        'recordsFiltered' => records_filtered_count,
        'data' => records
      }
    end

    def records
      model
        .order('id desc')
        .limit(@request.length)
        .offset(@request.start)
        .select('id', *@request.columns)
        .map { |r| r.slice(*@request.columns) }
    end

    def records_filtered_count
      if @request.search
        # TODO: handle filtered count
      else
        model.count
      end
    end
  end
end
