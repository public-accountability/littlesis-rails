# frozen_string_literal: true

class DatatablesParams
  attr_reader :draw, :start, :length, :search, :columns

  def initialize(params)
    @draw = params.require(:draw).to_i
    @start = params.require(:start).to_i
    @length = params.require(:length).to_i
    # @search = params.permit!(search: [:value, :regex]).to_h
    # @search[:regex] = ActiveModel::Type::Boolean.new.cast(@search[:regex] || false)
    @columns = parse_columns(params.fetch(:columns))
    freeze
  end

  def search_requested?
    search[:value].present?
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
