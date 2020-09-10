FactoryBot.define do
  factory :org_extension_definition, class: ExtensionDefinition do
    name { 'Org' }
    display_name { 'Organization' }
    has_fields { true }
  end

  factory :person_extension_definition, class: ExtensionDefinition do
    name { 'Person' }
    display_name { 'Person' }
    has_fields { true }
  end
end
