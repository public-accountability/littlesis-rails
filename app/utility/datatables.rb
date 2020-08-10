# frozen_string_literal: true

module Datatables
  Response = Struct.new(:draw, :recordsTotal, :recordsFiltered, :data, keyword_init: true)

  class Params
    attr_reader :params, :draw, :start, :length, :search, :columns, :order, :dataset, :matched

    extend Forwardable

    def_delegators :@params, :require, :permit, :permit!

    def self.from_hash(h)
      new ActionController::Parameters.new(h)
    end

    # input: ActionController::Parameters
    def initialize(params)
      @params = params
      @draw = @params.require(:draw).to_i
      @start = @params.require(:start).to_i
      @length = @params.require(:length).to_i
      @search = @params.require(:search).permit(:value, :regex).to_h.with_indifferent_access
      @search[:regex] = ActiveModel::Type::Boolean.new.cast(@search[:regex] || false)
      @columns = parse_columns(@params.fetch(:columns))

      if @params.key?(:order)
        @order = parse_order(@params.fetch(:order))
      else
        @order = nil
      end

      @dataset = @params[:dataset]&.downcase
      @matched = @params[:matched]&.downcase&.to_sym || :all

      if @dataset && !ExternalData.dataset?(@dataset)
        raise Exceptions::LittleSisError, 'Invalid Dataset'
      end

      freeze
    end

    def to_h
      { draw: @draw,
        start: @start,
        length: @length,
        search: @search,
        columns: @columns,
        order: @order }
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

    def query_string
      "%#{search_value}%"
    end

    def order_hash
      return {} if @order.blank?

      @order.each_with_object({}) do |order, hash|
        column = @columns[order[:column].to_i][:data].to_sym
        hash.store column, order[:dir].downcase.to_sym
      end
    end

    def order_sql
      return '' if @order.blank?

      @order.map do |o|
        @columns[o[:column].to_i][:data] + ' ' + o[:dir].upcase
      end.join(', ')
    end

    # Used only for the NYS Disclosure dataset
    def transaction_codes
      if @params['transaction_codes']
        @params['transaction_codes'].map(&:to_sym)
      else
        []
      end
    end

    private

    def parse_columns(columns)
      return columns if columns.is_a? Array

      to_array(columns).map do |column|
        column
          .permit(:data, :name, :searchable, :orderable, search: [:value, :regex])
          .to_h
          .with_indifferent_access
      end
    end

    # input: { '0' => { 'column' => '2', 'dir' => 'desc' },
    #          '1' => { 'column' => '0', 'dir' => 'asc' } }
    def parse_order(order)
      return order if order.is_a? Array

      to_array(order).map do |h|
        h.permit(:column, :dir).to_h.with_indifferent_access
      end
    end

    def to_array(hash)
      Range.new(0, nil).lazy.map(&:to_s).each_with_object([]) do |i, arr|
        break arr unless hash.key?(i)

        arr << hash[i]
      end
    end
  end
end
