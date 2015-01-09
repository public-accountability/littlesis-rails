namespace :twitter do
  desc "generates file of ids of connected people without twitter matches"
  task generate_entity_queue: :environment do
    TwitterQueue.generate
    print "generated file #{TwitterQueue::QUEUE_PATH} with ids of people with 5+ positions and no twitter accounts\n"
  end

  desc "attempts to match queued entities with twitter matches"
  task match_entities: :environment do
    ids = TwitterQueue.entity_ids
    client = Lilsis::Application.twitter

    num = ENV['NUM'].to_i || 100
    offset = ENV['OFFSET'].to_i || 0
    ids = ids[offset..(offset + num)]
    entities = Entity.find(ids)

    entities.each do |entity|
      print "#{entity.name}\n"
      entity_name_parts = entity.name_without_initials.strip.split(/\s+/)
      text = entity.affiliations.collect(&:name).join(' ')

      # get name words
      affiliation_words = OrgNames.get_name_words_from_text(text)

      # remove name words
      affiliation_words.reject! { |word| entity_name_parts.map(&:downcase).include? word.downcase }

      # remove common words
      affiliation_words = OrgNames.remove_common_words(affiliation_words)
      print "    affiliation words: #{affiliation_words.join(',')}\n"

      accounts = client.user_search(entity.name_without_initials)

      # only accounts with same first and last name
      accounts = accounts.select do |account|
        account_name_parts = account.name.to_s.strip.split(/\s+/)
        account_name_parts.count > 1 && entity_name_parts.count > 1 && ([account_name_parts.first[0], account_name_parts.last].map(&:downcase) == [entity_name_parts.first[0], entity_name_parts.last].map(&:downcase))
      end

      matching_accounts = {}

      accounts.each do |account|
        account_words = OrgNames.get_name_words_from_text(account.description.to_s)
        print "    #{account.name} (@#{account.screen_name}): #{account_words.join(',')}\n"
        matching_words = account_words & affiliation_words
        if matching_words.count > 0
          matching_accounts[account.screen_name] = matching_words 
          print "    matching words: #{matching_words.join(',')}\n"
        end
      end

      if matching_accounts.count > 0
        binding.pry
      end
    end
  end
end
