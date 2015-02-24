class GoogleSearch
  attr_accessor :search_url, :results

  def initialize
  end

  def search(q, page = 1)
    num = 10
    start = (page - 1) * num + 1
    @search_url = "https://www.googleapis.com/customsearch/v1?key=#{Lilsis::Application.config.google_custom_search_key}&cx=#{Lilsis::Application.config.google_custom_search_engine_id}&q=#{URI::encode(q)}&num=#{num}&start=#{start}"
    results = JSON.parse(Net::HTTP.get(URI(@search_url)))
    @results = results['items'].map { |result| { 'url' => result['link'], 'title' => result['title'] } }
    
    # g = Google::Search::Web.new(
    #   query: q, 
    #   rsz: num, 
    #   start: start, 
    #   api_key: Lilsis::Application.config.google_custom_search_key
    # )

    # @search_url = g.get_uri
    # @results = g.map { |result| { 'url' => result.uri, 'title' => result.title } }
  end
end