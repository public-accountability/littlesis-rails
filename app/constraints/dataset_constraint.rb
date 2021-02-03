# frozen_string_literal: true

class DatasetConstraint
  def initialize(check_id: false)
    @check_id = check_id
  end

  def matches?(request)
    dataset = request.params['dataset']
    id = request.params['id'] if @check_id

    is_dataset = ExternalDataset.datasets.key?(dataset.to_sym)

    if @check_id
      is_dataset && /\d+/.match?(id)
    else
      is_dataset
    end
  end
end
