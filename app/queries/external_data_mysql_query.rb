# frozen_string_literal: true

module ExternalDataMysqlQuery
  def self.run(params)
    relation = if params.search_requested?
                 dataset_search(params)
               else
                 ExternalData.public_send(params.dataset)
               end

    if %i[matched unmatched].include? params.matched
      relation = relation.public_send(params.matched, params.dataset)
    end

    Datatables::Response.new(draw: params.draw).tap do |response|
      response.recordsTotal = ExternalData.public_send(params.dataset).count
      response.recordsFiltered = relation.count
      response.data = to_datatables_array(relation: relation, params: params)
    end
  end

  # +params+ needs to be be a Datatables::Params
  def self.dataset_search(params)
    const_get("ExternalData::Datasets::#{params.dataset.classify}").send(:search, params)
  rescue NoMethodError, NameError => e
    raise e, "Search for dataset #{params.dataset} not yet implemented"
  end

  def self.to_datatables_array(relation:, params:)
    relation
      .preload(:external_entity, :external_relationship)
      .offset(params.start)
      .limit(params.length)
      .to_a
      .map(&:datatables_json)
  end
end
