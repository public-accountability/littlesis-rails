# frozen_string_literal: true

# This is a partial implementation of Server-Side rendering for datatables
# Reference: https://www.datatables.net/manual/server-side

class DatatablesService
  attr_reader :params, :draw, :start, :length, :search, :columns

  def initialize(params)
    @params = params.with_indifferent_access
    @dataset = params.fetch('dataset')

    @draw = @params.fetch(:draw).to_i
    @start = @params.fetch(:start).to_i
    @length = @params.fetch(:length).to_i
    @search = @params.fetch(:search).with_indifferent_access
    @search[:regex] = ActiveModel::Type::Boolean.new.cast(@search[:regex].presence || false)
    @columns = parse_columns @params.fetch('columns')

    @conditions = { dataset: @dataset }.tap do |x|
      if @search[:value].present?
        # TODO: handle search here
      end
    end
  end

  def results
    @results ||= {
      draw: @draw,
      recordsTotal: query.count,
      recordsFiltered: query.count,
      data: fetch_data
    }
  end

  def fetch_data
    query.includes(:external_entity).offset(@start).limit(@length).map do |ed|
      {
        id: ed.id,
        external_entity_id: ed.external_entity&.id,
        matched: ed.external_entity&.matched?,
        data: ed.data
      }
    end
  end

  def query
    ExternalData.where(@conditions)
  end

  private

  # Rails parses the database columns as a hash where the indexes starting at '0'
  # This converts that hash into an array of hashes
  def parse_columns(columns)
    Range.new(0, nil).lazy.map(&:to_s).each_with_object([]) do |i, arr|
      break arr unless columns.key?(i)

      arr << columns[i]
    end
  end
end
