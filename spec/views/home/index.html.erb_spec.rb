describe 'home/index.html.erb', type: :view do
  let(:stats) do
    [
      ["Citation", 3492870],
      ["Relationship", 1196877],
      ["Person", 189255],
      ["Organization", 70732],
      ["Business Person", 63684],
      ["Business", 23833],
      ["Political Fundraising Committee", 16309],
      ["Academic", 12091],
      ["Lobbyist", 11943],
      ["Political Candidate", 8683],
      ["Lawyer", 7547],
      ["Public Official", 6558],
      ["Private Company", 5605],
      ["Elected Representative", 4228],
      ["Media Personality", 3560],
      ["School", 3402],
      ["Government Body", 3399],
      ["Other Not-for-Profit", 3348],
      ["Public Company", 2283],
      ["Individual Campaign Committee", 2011],
      ["Philanthropy", 1786],
      ["Other Campaign Committee", 1642],
      ["Lobbying Firm", 1448],
      ["Membership Organization", 1201],
      ["Couple", 619],
      ["Law Firm", 601],
      ["Industry/Trade Association", 515],
      ["Policy/Think Tank", 296],
      ["Political Party", 217],
      ["Cultural/Arts", 214],
      ["PAC", 197],
      ["Consulting Firm", 172],
      ["Public Intellectual", 162],
      ["Government-Sponsored Enterprise", 114],
      ["Media Organization", 111],
      ["Labor Union", 103],
      ["Public Relations Firm", 94],
      ["Professional Association", 94],
      ["Social Club", 69]
    ]
  end

  before do
    assign(:dots_connected, rand(100_000).to_s.split(''))
    assign(:carousel_entities, Array.new(4) { build(:org) })
    assign(:stats, stats)
    assign(:newsletter_signup, NewsletterSignupForm.new)

    HomeController::DOTS_CONNECTED_LISTS.each do |_l|
      allow(List).to receive(:find).and_return(Faker::Internet.url)
    end

    render template: "home/index", layout: "layouts/application"
  end

  it 'has explore row with images' do
    css '#homepage-explore-row img', count: 3
  end

  it 'has correct page title' do
    expect(rendered).to have_selector "title", text: /\ALittleSis - Profiling the powers that be\z/
  end
end
