FactoryBot.define do
  factory :network_map, class: NetworkMap do
    title { "so many connections" }
    graph_data { OligrapherGraphData.new("nodes" => {}, "edges" => {}, "captions" => {}) }
    width { 960 }
    height { 960 }
    is_cloneable { true }
  end
end
