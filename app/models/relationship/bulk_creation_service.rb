# frozen_string_literal: true

class Relationship
  # Bulk creates relationships
  class BulkCreationService
    attr_reader :relationships, :errored_relationships, :successful_relationships
    # see utility.js
    BULK_RELATIONSHIP_ATTRIBUTES = [
      :name,
      :blurb,
      :primary_ext,
      :description1,
      :description2,
      :is_current,
      :start_date,
      :end_date,
      :amount,
      :currency,
      :goods,
      :is_board,
      :is_executive,
      :compensation,
      :degree,
      :education_field,
      :is_dropout,
      :dues,
      :percent_stake,
      :shares,
      :notes
    ].freeze

    def self.run(params)
      new(params).create!
    end

    # Bulk Relationship Paramters Struct:
    #  {
    #     entity1_id: Integer
    #     category_id: Integer
    #     reference: Hash
    #     relationships: [<Hash with BULK_RELATIONSHIP_ATTRIBUTES>]
    #}
    def initialize(params)
      @entity1 = Entity.find(params.require('entity1_id'))
      @category_id = params.require(:category_id).to_i
      @reference_params = params.require(:reference).permit(:name, :url).to_h
      @relationships = parse_relationships(params)
      @errored_relationships = []
      @successful_relationships = []
    end

    def create!
      frozen? and raise Exceptions::LittleSisError, "create! can only be called once"

      @relationships.each do |relationship|
        ApplicationRecord.transaction do
          make_or_get_entity(relationship) do |entity2|
            create_bulk_relationship(@entity1, entity2, relationship)
          end
        end
      end

      freeze
      self
    end

    private

    # @param params [ActionController::Parameters]
    # @return [Array<ActiveSupport::HashWithIndifferentAccess>]
    def parse_relationships(params)
      params.require(:relationships).map do |p|
        ParametersHelper.prepare_params(p.permit(*BULK_RELATIONSHIP_ATTRIBUTES))
      end
    end

    # @param relationship [Hash]
    # @yield [Entity] if entity could be successfully found or created
    def make_or_get_entity(relationship)
      entity = if relationship.fetch('name').to_i.zero?
                 Entity.create(relationship.slice('name', 'blurb', 'primary_ext'))
               else
                 Entity.find_by(id: relationship.fetch('name').to_i)
               end

      if entity.try(:persisted?)
        yield entity
      else
        @errored_relationships << relationship.merge('errorMessage' => 'Failed to find or create entity')
      end
    end

    # @param entity1 [Entity]
    # @param entity2 Entity
    # @param relationship [Hash]
    def create_bulk_relationship(entity1, entity2, relationship)
      r = Relationship.new(create_relationship_attributes(entity1, entity2, relationship))
      r.validate_reference(@reference_params)
      r.validate!
      r.save!
      r.add_reference(@reference_params)
      @successful_relationships << r.as_json(:url => true, :name => true)
    rescue ActiveRecord::ActiveRecordError, ActiveRecord::RecordInvalid => err
      @errored_relationships << r.as_json.merge('errorMessage' => err.message)
      # Rollback transaction but continue on to next relationship
      raise ActiveRecord::Rollback
    end

      # @param entity1 [Entity]
      # @param entity2 [Entity]
      # @param relationship [ActiveSupport::HashWithIndifferentAccess]
      # @return ActiveSupport::HashWithIndifferentAccess
    def create_relationship_attributes(entity1, entity2, relationship)
      h = relationship
            .merge(entity1_id: entity1.id,entity2_id: entity2.id, category_id: @category_id)
            .with_indifferent_access

      # correct relationship order for org-->person Education and relationships
      if [1, 2].include?(@category_id) && entity1.org? && entity2.person?
        h[:entity1_id] = entity2.id
        h[:entity2_id] = entity1.id
      end

      # handle special categories in client
      # see helpers/tools_helper.rb for what 30, 31, 50, and 51 represent
      if [30, 31, 50, 51].include?(@category_id)
        if @category_id == 50 || @category_id == 31
          h[:entity1_id] = entity2.id
          h[:entity2_id] = entity1.id
        end
        h[:category_id] = @category_id.to_s[0].to_i
      end

      # put extension attribution into label hash as expected by the rails nested paramaters convention
      h.slice(*Relationship.attribute_names).tap do |output|
        if Relationship.all_category_ids_with_fields.include?(h[:category_id])
          parameter_name = "#{Relationship::ALL_CATEGORIES[h[:category_id]]}_attributes".downcase.to_sym
          output[parameter_name] = h.slice(*Relationship.attribute_fields_for(h[:category_id]))
        end
      end
    end
  end
end
