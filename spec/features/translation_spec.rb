# frozen_string_literal: true

describe 'Translation', type: :feature do
  it "defaults to english" do
    visit '/database/about'
    expect(page).to have_text "LittleSis is a free database"
  end

  it "uses spanish upon request" do
    visit '/database/about?locale=es'
    expect(page).to have_text "Little Sis es una base de datos gratuita"
  end
end
