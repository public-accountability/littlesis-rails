require Rails.root.join('lib', 'query.rb').to_s
require Rails.root.join('lib', 'cmp.rb').to_s

namespace :cmp do
  namespace :orgs do
    desc 'saves spreadsheet of org matches'
    task save_org_matches: :environment do
      file_path = Rails.root
                    .join('data', "cmp_orgs_matched_#{Time.current.strftime('%F')}.csv").to_s

      blank_match_values = {
        match1_name: nil, match1_id: nil, match1_values: nil,
        match2_name: nil, match2_id: nil, match2_values: nil
      }

      sheet = Cmp.orgs.map do |cmp_org|
        attrs = cmp_org.attributes.merge(blank_match_values)

        EntityMatcher
          .find_matches_for_org(cmp_org.fetch(:cmpname))
          .first(2) # take first 2 matches
          .each.with_index do |match, idx|

          attrs["match#{idx + 1}_name".to_sym] = match.entity.name
          attrs["match#{idx + 1}_id".to_sym] = match.entity.id
          attrs["match#{idx + 1}_values".to_sym] = match.values.to_a.join('|')
        end
        attrs[:pre_selected] = Cmp::EntityMatch.matches.dig(cmp_org.cmpid.to_s, 'entity_id')
        attrs
      end
      Query.save_hash_array_to_csv file_path, sheet
      puts "Saved orgs to: #{file_path}"
    end

    desc 'import orgs excel sheet'
    task import: :environment do
      ThinkingSphinx::Callbacks.suspend!
      Cmp.import_orgs
      ThinkingSphinx::Callbacks.resume!
    end
  end

  namespace :people do
    desc 'save individuals with potential match information as csvs'
    task matches_as_csv: :environment do
      Cmp::Datasets.people
      Cmp::Datasets.relationships
      Cmp::Datasets.orgs

      file_path = Rails.root.join('data', 'cmp_individuals_with_match_info.csv').to_s

      people = Cmp::Datasets.people.values.map do |cmp_person|
        attrs = LsHash.new(littlesis_entity_id: '').merge!(cmp_person.attributes)

        # attrs['littlesis_entity_id'] = 'new' if attrs['match1_name'].blank?

        associated = CmpEntity
                       .where(cmp_id:Cmp::Datasets.relationships
                                .select { |r| r.fetch(:cmp_person_id, 'REL_ID') == attrs.fetch(:cmpid, "ATTR_ID") }
                                .map { |r| r.fetch(:cmp_org_id) })
                       .map(&:entity)

        attrs.merge!('associated_corps' => org_names)
      end

      Query.save_hash_array_to_csv file_path, people
    end
  end
end
