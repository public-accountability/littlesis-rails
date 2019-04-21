# frozen_string_literal: true

module ExternalDatasetService
  class InvalidMatchError < Exceptions::LittleSisError; end

  def self.validate_match!(**kwargs)
    const_get(kwargs[:external_dataset].name.capitalize)
      .new(**kwargs)
      .validate_match!
  end

  def self.match(**kwargs)
    const_get(kwargs[:external_dataset].name.capitalize)
      .new(**kwargs)
      .match
  end

  def self.unmatch(**kwargs)
    const_get(kwargs[:external_dataset].name.capitalize)
      .new(**kwargs)
      .unmatch
  end

  class Base
    attr_reader :external_dataset, :entity

    def initialize(external_dataset:, entity: nil)
      TypeCheck.check external_dataset, ExternalDataset
      TypeCheck.check entity, Entity, allow_nil: true
      @external_dataset = external_dataset

      if entity
        @entity = Entity.entity_for(entity)
      elsif @external_dataset.matched?
        @entity = @external_dataset.entity
      end
    end

    ##
    # Interface
    #

    def validate_match!
      raise NotImplementedError
    end

    def match
      raise NotImplementedError
    end

    def unmatch
      raise NotImplementedError
    end

    protected

    def requies_entity!
      raise ArgumentError unless @entity.is_a?(Entity)
    end
  end
end
