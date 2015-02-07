class GoogleSearch
  attr_accessor :search_url, :results

  def initialize
  end

  def search(q, page = 1)
    num = 8
    start = (page - 1) * num

    g = Google::Search::Web.new(
      query: q, 
      rsz: num, 
      start: start, 
      api_key: Lilsis::Application.config.google_custom_search_key
    )

    @search_url = g.get_uri
    @results = g.map { |result| { 'url' => result.uri, 'title' => result.title } }
  end
end