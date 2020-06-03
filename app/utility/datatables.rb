# frozen_string_literal: true

module Datatables
  Response = Struct.new(:draw, :recordsTotal, :recordsFiltered, :data, keyword_init: true)

  class Params
    attr_reader :params, :draw, :start, :length, :search, :columns, :dataset

    extend Forwardable

    def_delegators :@params, :require, :permit, :permit!

    # input: ActionController:Parameters
    def initialize(params)
      @params = params
      @draw = @params.require(:draw).to_i
      @start = @params.require(:start).to_i
      @length = @params.require(:length).to_i
      @search = @params.require(:search).permit(:value, :regex)
      @search[:regex] = ActiveModel::Type::Boolean.new.cast(@search[:regex] || false)
      @columns = parse_columns(@params.fetch(:columns))
      @dataset = @params[:dataset]&.downcase

      if @dataset && !ExternalData.dataset?(@dataset)
        raise Exceptions::LittleSisError, 'Invalid Dataset'
      end

      freeze
    end

    def to_h
      { draw: @draw, start: @start, length: @length, search: @search, columns: @columns }
    end

    def filtered?
      search_requested?
    end

    def search_requested?
      search_value.present?
    end

    def search_value
      @search[:value]
    end

    private

    # Datatables stores the database columns as a hash with keys as integers starting at 0.
    # This converts takes that data and converts it into an array of hashes
    def parse_columns(columns)
      Range.new(0, nil).lazy.map(&:to_s).each_with_object([]) do |i, arr|
        break arr unless columns.key?(i)

        arr << columns[i].permit(:data, :name, :searchable, :orderable, search: [:value, :regex]).to_h
      end
    end
  end
end
