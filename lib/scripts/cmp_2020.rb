# frozen_string_literal: true

CMP_USER_ID = 9948
CMP_TAG_ID = 11

PATHS = {
  entities: Rails.root.join('data/cmp_entities_2020.csv').to_s,
  relationships: Rails.root.join('data/cmp_relationships_2020.csv').to_s
}.freeze

CSV::Converters[:excel_null] = proc do |field|
  if field == '#NULL!'
    nil
  else
    field
  end
end

CSV::Converters[:trim_string] = proc do |field|
  field.strip.presence || field.strip
end

CSV::Converters[:weird_dot] = proc do |field|
  field.tap { |x| x.tr! "\u02d9", ' ' }
end

# Array of CSV:Row
RELATIONSHIPS = CSV.foreach(PATHS[:relationships],
                            :headers => :first_row,
                            :converters => %i[trim_string]).to_a.freeze
# keys = Cmp IDS
# values = Array of CSV:Row
RELATIONSHIPS_BY_ID = Hash.new { [] }.tap do |h|
  RELATIONSHIPS.each do |row|
    h[row['cmp_org_id']] = h[row['cmp_org_id']] << row
    h[row['cmp_relationship_id']] = h[row['cmp_relationship_id']] << row
  end
end.freeze

# Array of CSV:Row
ENTITIES = CSV.foreach(PATHS[:entities],
                       :headers => :first_row,
                       :converters => %i[weird_dot trim_string excel_null]).to_a.each do |row|

  # add column 'primary_ext' using the cmp relationship to determine the entity type
  row['primary_ext'] = if RELATIONSHIPS_BY_ID
                            .fetch(row['cmp_id'], [])
                            .any? { |r| r['cmp_org_id'] == row['cmp_id'] }
                         'Org'
                       else
                         'Person'
                       end
end.freeze

ENTITIES_BY_ID = {}.tap do |h|
  ENTITIES.each do |row|
    h[row['cmp_id']] = row
  end
end.freeze

def run(dry_run:)
  ENTITIES.each do |row|
    entity = if row['entity_id'].present?
               begin
                 Entity.find_with_resolved_merge(id: row['entity_id'])
               rescue ActiveRecord::RecordNotFound
                 Rails.logger.warn "No entity found wth id #{row['entity_id']}"
                 next
               end
             elsif CmpEntity.exists?(cmp_id: row['cmp_id'])
               CmpEntity.find_by(cmp_id: row['cmp_id']).entity
             else
               Rails.logger.info "Creating new entity: #{row['name']}"
               next if dry_run

               begin
                 Entity.create!(primary_ext: row['primary_ext'], name: row['name']).tap do |e|
                   e.add_tag(CMP_TAG_ID, CMP_USER_ID)
                 end
               rescue ActiveRecord::RecordInvalid => e
                 Rails.logger.warn "Failed to create new cmp entity #{row['name']}: #{e.message}"
                 next
               end
             end

    cmp_entity = CmpEntity.find_or_create_by!(entity: entity,
                                              entity_type: row['primary_ext'].downcase,
                                              cmp_id: row['cmp_id'])

    cmp_entity.update!(strata: row['Strata2020']) if row['Strata2020']
  end

  RELATIONSHIPS.each do |r|
    is_current = if r['In2017Not2019'].to_i.zero?
                   false
                 elsif r['In2019Not2017'].to_i.zero?
                   true
                 elsif r['In2017AND2019'].to_i.zero?
                   true
                 else
                   raise TypeError
                 end

    status19 = r['Status19'].to_i

    is_board = case status19
               when 1
                 true
               when 2
                 false
               end

    is_executive = status19 == 2 ? true : nil

    cmp_affiliation_id = r.fetch('cmp_affiliation_id')

    relationship = if CmpRelationship.exists?(cmp_affiliation_id: cmp_affiliation_id)
                     Rails.logger.debug "Found existing CMP relationship: #{cmp_affiliation_id}"
                     CmpRelationship.find_by(cmp_affiliation_id: cmp_affiliation_id).relationship
                   elsif r['relationship_id'].present? && Relationship.exists?(id: r['relationship_id'])
                     Relationship.find_by(id: r['relationship_id'])
                   end

    if relationship.nil? && r['relationship_id'].present?
      Rails.logger.warn "Could not find relationship #{r['relationship_id']}"
      next
    end

    if relationship.present?
      unless dry_run
        relationship.update!(is_current: is_current)

        if relationship.position.present?
          relationship.position.update!(is_board: is_board, is_executive: is_executive)
        else
          Rails.logger.warn "Relationship #{relationship.id} has no associated position (CMP affiliation: #{cmp_affiliation_id})"
        end
      end
    else # create new relationship
      entity = CmpEntity.find_by(cmp_id: r['cmp_person_id'])&.entity
      related = CmpEntity.find_by(cmp_id: r['cmp_org_id'])&.entity

      unless entity
        if ENTITIES_BY_ID.key? r['cmp_person_id']
          Rails.logger.info "Cmp person #{r['cmp_person_id']} not yet imported."
        else
          Rails.logger.warn "Could not find cmp_person_id #{r['cmp_person_id']}."
        end
        next
      end

      unless related
        if ENTITIES_BY_ID.key? r['cmp_org_id']
          Rails.logger.info "Cmp org #{r['cmp_org_id']} not yet imported."
        else
          Rails.logger.warn "Could not find cmp_org_id #{r['cmp_org_id']}."
        end
        next
      end

      attrs = {
        is_current: is_current,
        category_id: RelationshipCategory.name_to_id[:position],
        entity: entity,
        related: related,
        position_attributes: { is_board: is_board, is_executive: is_executive }
      }

      Rails.logger.info "Creating new relationship: #{attrs}"

      unless dry_run
        Relationship.create!(attrs).tap do |relationship|
          relationship.add_tag(CMP_TAG_ID, CMP_USER_ID)

          CmpRelationship.create!(relationship: relationship,
                                  cmp_affiliation_id: cmp_affiliation_id,
                                  cmp_org_id: r['cmp_org_id'],
                                  cmp_person_id: r['cmp_person_id'],
                                  status19: status19)
        end
      end
    end
  end
end

PaperTrail.request(whodunnit: CMP_USER_ID.to_s) do
  run(dry_run: false)
end
