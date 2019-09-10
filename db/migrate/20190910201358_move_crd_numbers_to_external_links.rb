class MoveCrdNumbersToExternalLinks < ActiveRecord::Migration[6.0]
  def up
    BusinessPerson.where.not(crd_number: nil).each do |business_person|
      ExternalLink.create!(link_type: :crd,
                           entity_id: business_person.entity_id,
                           link_id: business_person.crd_number.to_s)
    end

    Business.where.not(crd_number: nil).each do |business|
      ExternalLink.create!(link_type: :crd,
                           entity_id: business.entity_id,
                           link_id: business.crd_number.to_s)
    end
  end
end
