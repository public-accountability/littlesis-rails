FactoryBot.define do
  factory :dashboard_bulletin do
    title { Faker::Kpop.solo }
    content do
      <<~HTML
        <h1>Dashboard Bulletin</h1>

        <h2>Content</h2>

        <ul>
          <li>one</li>
          <li>two</li>
        </ul>
      HTML
    end
  end
end
