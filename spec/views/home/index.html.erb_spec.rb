describe 'home/index.html.erb', type: :view do
  let(:stats) do
    [
      [3492870, "Citation"],
      [1196877, "Relationship"],
      [189255, "Person"],
      [70732, "Organization"],
      [63684, "Business Person"],
      [23833, "Business"],
      [16309, "Political Fundraising Committee"],
      [12091, "Academic"],
      [11943, "Lobbyist"],
      [8683, "Political Candidate"],
      [7547, "Lawyer"],
      [6558, "Public Official"],
      [5605, "Private Company"],
      [4228, "Elected Representative"],
      [3560, "Media Personality"],
      [3402, "School"],
      [3399, "Government Body"],
      [3348, "Other Not-for-Profit"],
      [2283, "Public Company"],
      [2011, "Individual Campaign Committee"],
      [1786, "Philanthropy"],
      [1642, "Other Campaign Committee"],
      [1448, "Lobbying Firm"],
      [1201, "Membership Organization"],
      [619, "Couple"],
      [601, "Law Firm"],
      [515, "Industry/Trade Association"],
      [296, "Policy/Think Tank"],
      [217, "Political Party"],
      [214, "Cultural/Arts"],
      [197, "PAC"],
      [172, "Consulting Firm"],
      [162, "Public Intellectual"],
      [114, "Government-Sponsored Enterprise"],
      [111, "Media Organization"],
      [103, "Labor Union"],
      [94, "Public Relations Firm"],
      [94, "Professional Association"],
      [69, "Social Club"]
    ]
  end

  before do
    assign(:dots_connected, rand(100_000).to_s.split(''))
    assign(:carousel_entities, Array.new(4) { build(:org) })
    assign(:stats, stats)
    HomeController::DOTS_CONNECTED_LISTS.each do |l|
      expect(List).to receive(:find).with(l[0]).and_return(Faker::Internet.url)
    end
    render template: "home/index", layout: "layouts/application"
  end

  it 'has explore row with images and links' do
    css '#explore-row img', count: 2
    css '#explore-row a', count: 3
  end

  it 'has correct page title' do
    expect(rendered).to have_selector "title", text: /\ALittleSis - Profiling the powers that be\z/
  end
end
