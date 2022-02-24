# frozen_string_literal: true

module Pages
  READER = lambda do |page, locale|
    Kramdown::Document.new(
      File.read(Rails.root.join('config', 'pages', "#{page}.#{locale}.md"))
    ).to_html.html_safe
  end

  PAGES = %i[disclaimer].freeze

  HTML = PAGES.each_with_object({}) do |page, h|
    h[page] = {
      en: READER.call(page, :en),
      es: READER.call(page, :es)
    }
  end.with_indifferent_access.freeze

  def self.get(page, locale = :en)
    HTML.dig(page, locale)
  end
end
