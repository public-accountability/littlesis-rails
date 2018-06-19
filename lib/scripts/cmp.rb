require 'csv'

require Rails.root.join('lib', 'cmp.rb').to_s

# potential_matches_csv = "/littlesis/cmp/potential_cmp_matches.csv"
potential_matches_csv = Rails.root.join('data', 'potential_cmp_matches.csv')
minimum_entity_link_count = 10

print CSV.generate_line(%w[cmpid cmp_full_name entity_name entity_id entity_url entity_link_count cmp_relationships, match_values])


def include_entity?(match_values)
  (match_values.include?('similar_first_name') || match_values.include?('same_first_name')) &&
    match_values.include?('same_last_name') &&
    !match_values.include?('different_middle_name')
end


CSV.foreach(potential_matches_csv, headers: true) do |row|
  match_values = row['match_values'].split('|')
  entity = Entity.find_by(id: row['match_id'])
  next if entity.nil?

  if (entity.link_count >= minimum_entity_link_count) || include_entity?(match_values)

    csv_line = CSV.generate_line([
                                   row['cmpid'],
                                   row['fullname'],
                                   entity.name,
                                   entity.id,
                                   "https://littlesis.org/entities/#{entity.id}",
                                   entity.link_count,
                                   Cmp::Datasets
                                     .people[row['cmpid']]
                                     .cmp_relationships_with_title
                                     .join('|'),
                                   row['match_values']
                                 ])

    print csv_line
  else
    # Cmp::Datasets.people[row['cmpid']].import!
    # Cmp::Datasets.people[row['cmpid']].clear_matches
  end
end
