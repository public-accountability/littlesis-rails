FactoryBot.define do
  factory :network_map, class: NetworkMap do
    title { "so many connections" }
    graph_data { OligrapherGraphData.new("nodes" => {}, "edges" => {}, "captions" => {}) }
    width { 960 }
    height { 960 }
    is_cloneable { true }
  end

  factory :network_map_version3, class: NetworkMap do
    title { "network map" }
    graph_data { { "nodes" => {}, "edges" => {}, "captions" => {} } }
    is_private { false }
    is_cloneable { true }
  end
end
