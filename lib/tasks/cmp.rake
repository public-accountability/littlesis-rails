require Rails.root.join('lib', 'cmp.rb')

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
      Cmp.import_orgs
    end
  end
end
