FactoryBot.define do
  factory :toolkit_page do
    markdown do
      <<~MARKDOWN
        # toolkit page

        ## content

        * one
        * two
      MARKDOWN
    end

    name { 'toolkit_page' }
    title { 'a toolkit page' }
  end
end
