# frozen_string_literal: true

module Exceptions
  class LittleSisError < StandardError; end
  class PermissionError < StandardError; end
  class NotFoundError < StandardError; end
  class MissingApiTokenError < StandardError; end
  class InvalidRelationshipCategoryError < StandardError; end
  class RestrictedUserError < StandardError; end
  class UserCannotEditError < StandardError; end
  class InvalidEntityIdError < LittleSisError; end
  class OligrapherAssetsError < LittleSisError; end
  class MatchingError < LittleSisError; end
  class EditingDisabled <  LittleSisError; end


  class CannotRestoreError < StandardError
    def message
      "Cannot restore a model that has not yet been deleted"
    end
  end

    class MissingEntityAssociationDataError < StandardError
      def message
        "Missing association data for this Entity"
      end
    end

    class UnauthorizedBulkRequest < StandardError
      def message
        "User lacks priveleges to submit bulk request of this size"
      end
    end

    class InvalidUrlError < ArgumentError
      def message
        "The URL is invalid"
      end
    end

    class ModelIsDeletedError < ActiveRecord::ActiveRecordError
      def message
        "The model has been deleted"
      end
    end

    class ThatsWeirdError < StandardError
    def message
      "Well, that's weird."
    end
  end

  class MergedEntityError < StandardError
    attr_reader :merged_entity

    def initialize(merged_entity)
      super
      @merged_entity = merged_entity
    end

    def message
      "Tried to retrieve entity that has been merged into entity w/ id #{merged_entity.id}"
    end
  end

  class RedundantMergeReview < StandardError
    def message
      "Attempting to review a merge request that has already been reviewed."
    end
  end

  class MissingCategoryIdParamError < StandardError
    def message
      'missing required paramater: "category_id"'
    end

    def error_hash
      { 'category_id' => 'is absent' }
    end
  end
end
