# frozen_string_literal: true

module ExternalDataSphinxQuery
  def self.run(params)
    search_term = params.search_requested? ? params.search_value : nil

    sphinx_search = ExternalData.search(search_term, search_options(params))

    Datatables::Response.new(draw: params.draw).tap do |response|
      response.recordsTotal = ExternalData.public_send(params.dataset).count
      response.recordsFiltered = sphinx_search.count
      response.data = make_datatables_array(sphinx_search)
    end
  end

  def self.search_options(params)
    {
      indices: ["external_data_#{params.dataset}_core"],
      order: params.order_sql,
      page: (params.start / params.length) + 1,
      per_page: params.length,
      sql: active_record_sql(params.dataset)
    }
  end

  def self.active_record_sql(dataset)
    case dataset
    when 'nyc_disclosure'
      { :include => :external_relationship }
    else
      {}
    end
  end

  def self.make_datatables_array(sphinx_search)
    sphinx_search.to_a.map(&:datatables_json)
  end

  private_class_method :search_options, :active_record_sql, :make_datatables_array
end
