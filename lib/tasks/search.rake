namespace :search do
  desc "updates entity delta index if any entities have been updated within last two minutes"
  task update_entity_delta_index: :environment do
    entities = Entity.unscoped.where("updated_at > ?", 2.minutes.ago)
    puts "entities updated within last two minutes: #{entities.count}\n"

    if entities.count > 0
      puts "updating entity delta index...\n"

      interface.configure

      delta_index = ThinkingSphinx::Configuration.instance.indices.find { |i| i.name == "entity_delta" }
      delta_index.delta_processor.index(delta_index)
    end
  end
end