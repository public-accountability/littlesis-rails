FactoryBot.define do
  factory :toolkit_page do
    markdown <<~MARKDOWN
               # toolkit page

               ## content

               * one
               * two
             MARKDOWN

    name 'toolkit_page'
    title 'a toolkit page'
  end
end
