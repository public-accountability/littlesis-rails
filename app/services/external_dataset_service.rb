# frozen_string_literal: true

module ExternalDatasetService
  # For IAPD it:
  #   * adds business or business person extension
  #   * adds crd number
  class Iapd < SimpleDelegator
    def validate_match!(entity_or_entity_id)
    end

    def match(entity_or_entity_id)
    end

    def unmatch
    end
  end

  class OtherDataset < SimpleDelegator
    # other datasets
  end
end
