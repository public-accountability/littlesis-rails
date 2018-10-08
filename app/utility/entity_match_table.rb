# frozen_string_literal: true

class EntityMatchTable
  PERMITTED_MODELS = %w[NyFiler].freeze

  HEADERS = {
    'NyFiler' => ['Name', 'Filer ID', 'Matched Entity']
  }.freeze

  SCOPE = Hash.new(:itself).tap do |h|
    h['NyFiler'] = :datatable
  end.freeze

  attr_reader :model, :model_type

  # input: String | Symbol
  def initialize(model_type, page: 1, per_page: 20)
    raise ArgumentError unless PERMITTED_MODELS.include?(model_type.to_s)

    @model_type = model_type.to_s
    @model = @model_type.constantize
    @page = page.to_i
    @per_page = per_page.to_i
    @scope = SCOPE[@model_type]
    freeze
  end

  def headers
    HEADERS[@model_type]
  end

  def records
    return @records if defined?(@records)

    @records = @model
                 .send(@scope)
                 .page(page)
                 .per(per_page)
                 
  end
end
