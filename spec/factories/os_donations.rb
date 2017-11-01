FactoryGirl.define do
  sequence :fec_cycle_id do |n|
    "2012-#{n}"
  end
  
  sequence :donation_microfilm do |n|
    "xyz#{n}"
  end
  

  factory :os_donation do
    cycle "2012"
    fectransid "MyString"
    fec_cycle_id { generate(:fec_cycle_id) }
    contribid "MyString"
    contrib "MyString"
    recipid "MyString"
    orgname "MyString"
    ultorg "MyString"
    realcode "x"
    date "2016-07-22"
    amount 1
    street "MyString"
    city "MyString"
    state "NY"
    recipcode "12"
    transactiontype ""
    cmteid "MyString"
    otherid "MyString"
    gender 'X'
    microfilm { generate(:donation_microfilm) }
    occupation "MyString"
    employer "MyString"
    source ""
  end
end
