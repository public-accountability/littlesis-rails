# frozen_string_literal: true

iapd_advisors_file_path = Rails.root.join('iapd_filers_2019-01-23-matched.csv').to_s

def existing_match(entity_id, crd_number)
  entity = Entity.find(entity_id)
  entity.add_extension('Business')

  if entity.business.crd_number.present?
    if entity.business.crd_number == crd_number
      Rails.logger.info "[iapd] entity #{entity.id} is already matched"
    else
      Rails.logger.warn "[iapd] #{entity.id} is matched to a different number!"
      Rails.logger.warn "[iapd] #{entity.id} is matched to #{entity.business.crd_number}, trying to match with #{crd_number}"
    end

  else
    entity.business.update!(crd_number: crd_number)
  end
rescue ActiveRecord::RecordNotFound
  Rails.logger.warn "[iapd] could not find entity #{entity_id}"
end


def create_new_entity(row)
  entity = Entity.create!(name: OrgName.format(row['name']),
                          primary_ext: 'Org',
                          last_user_id: 1)
  entity.add_extension('Business', { crd_number: row['crd_number'].to_i })
end


CSV.foreach(iapd_advisors_file_path,  headers: true) do |row|
  match_data = row['match'].strip
  crd_number = row['crd_number'].to_i

  PaperTrail.request(whodunnit: '1') do

    if match_data.upcase == 'Y'
      Rails.logger.info "[iapd] Adding crd_number #{crd_number} to entity #{row['matched_entity_id']}"
      existing_match(row['matched_entity_id'], crd_number)
    elsif match_data.upcase == 'NEW'
      Rails.logger.info "[iapd] Creating new entity for crd_number #{crd_number}"
      create_new_entity(row)
    elsif match_data.match?(/^\d+$/)
      Rails.logger.info "[iapd] Adding crd_number #{crd_number} to entity #{match_data}"
      existing_match(match_data, crd_number)
    else
      raise 'INVALID MATCH DATA'
    end
  end
end
