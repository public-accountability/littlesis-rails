# frozen_string_literal: true

module FECContributionsQuery
  def self.run(entity)
    raise Exceptions::LittleSisError, "Can only get contributions for people" if entity.org?
  end
end
