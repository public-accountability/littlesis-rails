FactoryBot.define do
  factory :toolkit_page do
    name { 'toolkit_page' }
    title { 'a toolkit page' }
    content do
      <<~HTML
        <h1>Toolkit Page</h1>

        <h2>Content</h2>

        <ul>
          <li>one</li>
          <li>two</li>
        </ul>
      HTML
    end
  end
end
