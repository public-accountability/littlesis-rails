class GoogleSearch
  attr_accessor :search_url, :results

  def initialize(cse_id=nil)
    @cse_id = (cse_id or Lilsis::Application.config.google_custom_search_engine_id)
  end

  def search(q, page = 1, detailed=false)
    num = 10
    start = (page - 1) * num + 1
    @search_url = "https://www.googleapis.com/customsearch/v1?key=#{Lilsis::Application.config.google_custom_search_key}&cx=#{@cse_id}&q=#{URI::encode(q)}&num=#{num}&start=#{start}"
    @results = JSON.parse(Net::HTTP.get(URI(@search_url)))['items']
  end
end