# frozen_string_literal: true

class DatasetConstraint
  DATASETS = ExternalData::DATASETS.keys.map(&:to_s).to_set.freeze

  def initialize(check_id: false)
    @check_id = check_id
  end

  def matches?(request)
    dataset = request.params['dataset']
    id = request.params['id'] if @check_id

    if @check_id
      DATASETS.include?(dataset) && /\d+/.match?(id)
    else
      DATASETS.include?(dataset)
    end
  end
end
