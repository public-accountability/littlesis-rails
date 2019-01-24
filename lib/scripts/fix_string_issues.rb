# frozen_string_literal: true

# Some fields in our database have some incorrectly quoted characters
# and other incorrect strings.

def contains_problem_chars?(str)
  str.include?('\\\'') || str.include?('\\"') || str.include?("\r\n\\")
end

def clean_string(str)
  str.gsub('\\"', '"').gsub('\\\'', "'").gsub("\r\n\\", '')
end

Entity.all.find_each do |entity|
  next if entity.summary.blank?

  if contains_problem_chars?(entity.summary)
    ColorPrinter.print_blue "Updating entity: #{entity.name} (#{entity.id})"
    entity.update_column :summary, clean_string(entity.summary)
  end
end

Relationship.all.find_each do |rel|
  next if rel.notes.blank?

  if contains_problem_chars?(rel.notes)
    ColorPrinter.print_blue "Updating relationship #{rel.id}"
    rel.update_column :notes, clean_string(rel.notes)
  end
end
