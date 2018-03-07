require Rails.root.join('lib', 'query.rb').to_s
require Rails.root.join('lib', 'cmp.rb').to_s

namespace :cmp do
  namespace :orgs do
    desc 'find orgs that have 2 or more matches'
    task with_multiple_matches: :environment do
      Cmp.orgs.select { |cmp_org| cmp_org.entity_match.count >= 2 }. each do |cmp_org|
        matches = cmp_org.matches
        puts '|----------------------------------------------------------|'
        puts "name: #{cmp_org.fetch(:cmpname)}"
        puts "cmpid: #{cmp_org.cmpid}"
        puts "match one: #{matches[:one]}"
        puts "match two: #{matches[:two]}"
      end
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

        #attrs['littlesis_entity_id'] = 'new' if attrs['match1_name'].blank?

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
