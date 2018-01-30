namespace :stats do
  desc "calculates new relationships, entities, and users for the given year"
  task :year, [:year] => :environment do |_, args|
    year = args[:year].to_i
    range = Date.new(year, 1, 1)..Date.new(year, 12, 31)
    ColorPrinter.print_blue "Calculating stats for #{year}"
    new_relationships = Relationship.where(created_at: range).count
    ColorPrinter.print_green "New Relationships: #{new_relationships}"
    new_entities = Entity.where(created_at: range).count
    ColorPrinter.print_green "New Entities: #{new_entities}"
    new_users = User.where(created_at: range).count
    ColorPrinter.print_green "New Users: #{new_users}"
  end
end
