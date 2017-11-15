FactoryBot.define do
  factory :help_page do
    markdown <<~MARKDOWN
               # editing relationships

               ## content

               * one
               * two
             MARKDOWN

    name 'editing_relationships'
    title 'how to edit relationships'
    last_user_id 1
  end
end
