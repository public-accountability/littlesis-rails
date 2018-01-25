namespace :cmp do
  namespace :orgs do

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
  end
end
