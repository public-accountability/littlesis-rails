FactoryGirl.define do
  factory :network_map, class: NetworkMap do
    title "so many connections"
    data "{\"entities\":[],\"rels\":[],\"texts\":[]}"
    width 960
    height 960
    is_cloneable true
  end
end
