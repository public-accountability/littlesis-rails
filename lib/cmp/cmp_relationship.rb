# frozen_string_literal: true

module Cmp
  class CmpRelationship
    BOARD_INTS = [2, 3, 4, 5].to_set.freeze
    EXECUTIVE_INTS = [1, 2, 3, 4, 5].to_set.freeze

    attr_reader :attributes, :status, :affiliation_id
    delegate :[], :fetch, to: :attributes

    def initialize(attrs)
      @attributes = LsHash.new(attrs)
      # status indicating timeframe of relationships
      # possible values:
      #   :only_2015, :only_2016, :both_years, :change, :unknown
      @status = derive_status
      @affiliation_id = @attributes.fetch('cmpid')
      @cmp_org_id = @attributes.fetch('cmp_org_id')
      @cmp_person_id = @attributes.fetch('cmp_person_id')
    end

    def import!
      return if skip_import?
      Cmp.transaction do
        relationship = find_matching_relationship
        relationship = new_relationship if relationship.nil?

        relationship.update! relationship_attributes
        relationship.add_tag(Cmp::CMP_TAG_ID)
        ::CmpRelationship.find_or_create_by!(relationship: relationship,
                                             cmp_affiliation_id: @affiliation_id,
                                             cmp_org_id: @cmp_org_id.to_i,
                                             cmp_person_id: @cmp_person_id.to_i)
      end
    end

    private

    ##
    # Import helpers
    #

    def new_relationship
      Relationship.create!(basic_relationship_attributes)
    end

    # --> <Relationship> | nil
    # tries to find a matching relationship in our database either
    # via an existing CmpRelationship or by finding matching relationship.
    def find_matching_relationship
      by_cmp_relationship = ::CmpRelationship.find_by(cmp_affiliation_id: @affiliation_id)&.relationship
      return by_cmp_relationship if by_cmp_relationship

      rel = Relationship.find_by(basic_relationship_attributes)
      return nil if rel.nil?
      return nil if different?(rel.position.is_board, position_attributes.fetch(:is_board))
      return nil if different?(rel.position.is_executive, position_attributes.fetch(:is_executive))
      return rel
    end

    def basic_relationship_attributes
      {
        category_id: RelationshipCategory.name_to_id[:position],
        entity: person_entity,
        related: org_entity
      }
    end

    # Compares two values and determines if they different.
    # if either a or b is nil, then they are considered the same,
    # regardless of what the value of the other one is
    # Used to determine if a new relationship should be created
    # or if the found relationship is okay.
    def different?(a, b)
      return false if a.nil? || b.nil?
      a != b
    end

    def org_entity
      return @_org_entity if defined?(@_org_entity)
      @_org_entity = CmpEntity.find_by(cmp_id: @cmp_org_id, entity_type: :org).entity
    end

    def person_entity
      return @_person_entity if defined?(@_person_entity)
      @_person_entity = CmpEntity.find_by(cmp_id: @cmp_person_id, entity_type: :person).entity
    end

    def skip_import?
      if ::CmpRelationship.find_by(cmp_affiliation_id: @affiliation_id)&.relationship_id
        Rails.logger.warn "CMP Relationship #{@affiliation_id} has already been imported"
        return true
      end

      unless CmpEntity.exists?(cmp_id: @cmp_org_id)
        Rails.logger.warn "Cannot import #{@affiliation_id} because cmp org \##{@cmp_org_id} does not exist"
        return true
      end

      unless CmpEntity.exists?(cmp_id: @cmp_person_id)
        Rails.logger.warn "Cannot import #{@affiliation_id} because cmp person \##{@cmp_person_id} does not exist"
        return true
      end

      return false
    end

    ##
    # Relationship attribute helpers
    #
    def relationship_attributes
      {
        description1: description1,
        is_current: is_current,
        start_date: start_date,
        end_date: end_date,
        position_attributes: position_attributes,
        last_user_id: Cmp::CMP_SF_USER_ID
      }
    end

    def description1(job_title = nil)
      job_title = fetch('job_title', nil) if job_title.nil?
      standardized_position = fetch('standardized_position', nil)

      if job_title.present? && !Regexp.new('^\d+$').match?(job_title)
        return job_title if job_title.length <= 50
        simplified_job_title = long_job_title(job_title)
        if simplified_job_title.present?
          return simplified_job_title.truncate(100, separator: ' ', omission: '')
        end
      end

      if standardized_position.present?
        return 'CEO' if standardized_position.include?('CEO')
        return 'CFO' if standardized_position.include?('CFO')
        return 'COO' if standardized_position.include?('COO')
        return 'CIO' if standardized_position.include?('CIO')
        return 'Secretary' if standardized_position.downcase.include?('secretary')
        return 'Treasurer' if standardized_position.downcase.include?('treasurer')
        return 'Comptroller' if standardized_position.include?('Comptroller')
        return 'Vice Chairman' if standardized_position.include?('Vice Chairman')
        return 'Partner' if standardized_position.include?('Partner')
        return standardized_position.delete('+').strip if standardized_position.length < 40
      end
    end

    def long_job_title(title)
      return Regexp.new('(.*);').match(title)[1] if title.include? ';'
      return Regexp.new('(.*\)),').match(title)[1] if title.include? '),'
      return Regexp.new('(.*),').match(title)[1] if title.include? ','
      return Regexp.new('(.*)-').match(title)[1] if title.include? '-'
    end

    def start_date
      if /^\d{4}$/.match? fetch('appointment_year', '')
        "#{fetch('appointment_year')}-00-00"
      elsif @status == :only_2016
        '2016-00-00'
      end
    end

    def end_date
      '2015-00-00' if @status == :only_2015
    end

    def is_current
      return false if @status == :only_2015
      return nil
    end

    def position_attributes
      year = @status == :only_2015 ? '2015' : '2016'
      {
        is_board: board_member?(year),
        is_executive: executive?(year)
      }
    end

    def status_changed
      return false unless @status == :change
      (board_member?('2015') != board_member?('2016')) || (executive?('2015') != executive?('2016'))
    end

    def board_member?(year)
      BOARD_INTS.include? fetch("board_status_#{year}").to_i
    end

    def executive?(year)
      EXECUTIVE_INTS.include? fetch("ex_status_#{year}").to_i
    end

    # 'human readable symbol for variable NewIn2016
    def derive_status
      case fetch('new_in_2016').to_i
      when 0
        :only_2015
      when 1
        :change
      when 2
        :only_2016
      when 8
        :both_years
      else
        :unknown
      end
    end
  end
end
