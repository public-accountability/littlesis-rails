# frozen_string_literal: true

module Pages
  READER = lambda do |page, locale|
    Kramdown::Document.new(
      File.read(Rails.root.join('config', 'pages', "#{page}.#{locale}.md"))
    ).to_html.html_safe
  end

  LOCALES = %i[en es].freeze
  PAGES = %i[disclaimer about].freeze

  HTML = PAGES.each_with_object({}) do |page, h|
    h[page] = {}
    LOCALES.each { |locale| h[page][locale] = READER.call(page, locale) }
  end.with_indifferent_access.freeze

  def self.get(page, locale = :en)
    locale = :en unless LOCALES.include?(locale)
    HTML.dig(page, locale)
  end
end
