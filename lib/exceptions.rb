module Exceptions
  class PermissionError < StandardError; end
  class NotFoundError < StandardError; end
  class MissingApiTokenError < StandardError; end
  class RestrictedUserError < StandardError; end
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
end
