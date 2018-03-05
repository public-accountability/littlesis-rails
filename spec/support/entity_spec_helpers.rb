# rubocop:disable Style/MutableConstant
#
# creates and builds fake entities
module EntitySpecHelpers
  TRAVERSES = ['Frank Traverse', 'Kit Traverse', 'Lake Traverse',
               'Mayva Traverse', 'Reef Traverse', 'Webb Traverse']

  CHUMS = ['Miles Blundell', 'Chick Counterfly', 'Lindsay Noseworth',
           'Darby Suckling', 'Randolph St. Cosmo']

  FRIENDS_OF_CHUMS = ['Lew Basnight', 'Erlys Rideout', 'Cyprian Latewood',
                      'Yashmeen Halfcourt', 'Nikola Tesla']

  BAD_VIBES = ['Scarsdale Vibe', 'Colfax Vibe', 'Dittany Vibe',
               'Edwarda Vibe', 'Fleetwood Vibe', 'Wilshire Vibe']

  ATD_CHARACTERS = TRAVERSES + CHUMS + FRIENDS_OF_CHUMS + BAD_VIBES

  %i[ATD_CHARACTERS TRAVERSES CHUMS FRIENDS_OF_CHUMS BAD_VIBES].each do |set|
    define_singleton_method(set.to_s.downcase) do |num: 3, method: :create|
      const_get(set).sample(num).map do |person|
        FactoryBot.send(method, :entity_person, name: person)
      end
    end
  end

  def self.person(*names)
    first = name_for 'first'
    last = name_for 'last'
    middle = names.include?('middle') ? name_for('middle') : nil
    name = "#{first} #{middle.nil? ? '' : middle + ' '}#{last}"
    entity = FactoryBot.build(:person, name: name)
    person = FactoryBot.build(:a_person, name_first: first, name_last: last, name_middle: middle)
    names
      .delete_if { |x| x == 'middle' } # middle name is already handled above
      .each { |type| person.send "name_#{type}=", name_for(type) }
    entity.person = person
    entity
  end

  private_class_method def self.name_for(type)
    case type
    when 'first', 'middle', 'nick'
      Faker::Name.first_name
    when 'prefix'
      Faker::Name.prefix
    when 'suffix'
      Faker::Name.suffix
    when 'last', 'maiden'
      Faker::Name.last_name
    else
      raise ArgumentError
    end
  end
end
# rubocop:enable Style/MutableConstant
