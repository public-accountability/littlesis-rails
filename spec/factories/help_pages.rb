FactoryBot.define do
  factory :help_page do
    markdown do
      <<~MARKDOWN
        # editing relationships

        ## content

        * one
        * two
    MARKDOWN
    end
    name { 'editing_relationships' }
    title { 'how to edit relationships' }
    last_user_id { 1 }
  end
end
