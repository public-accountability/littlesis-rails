module EntitySpecHelpers

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
