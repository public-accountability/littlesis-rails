FactoryBot.define do

  factory :loeb, class: Entity do
    name { "Daniel S Loeb" }
    blurb { "CEO of Third Point LLC" }
    primary_ext { "Person" }
    last_user_id { 1 }
  end

  factory :nrsc, class: Entity do
    name { "National Republican Senatorial Committee" }
    primary_ext { "Org" }
    last_user_id { 1 }
  end

  factory :loeb_donation, class: Relationship do
    entity1_id { 10551 }
    entity2_id { 28799 }
    category_id { 5 }
    description1 { "Campaign Contribution" }
    description2 { "Campaign Contribution" }
    amount { 61200 }
    filings { 2 }
    start_date { "2010-00-00" }
    end_date { "2011-00-00" }
    is_deleted { false }
    last_user_id { 1 }
    is_gte { false }
  end

  factory :loeb_donation_one, class: OsDonation do
    cycle { '2012' }
    fectransid { '1120620120011115314' }
    contribid { 'U00000038301' }
    contrib { "LOEB, DANIEL MR" }
    recipid { "C00027466" }
    orgname { "Third Point LLC" }
    realcode { "F2700" }
    date { "2011-11-29" }
    amount { 30800 }
    city { "NEW YORK" }
    state { "NY" }
    zip { '10022' }
    recipcode { 'RP' }
    transactiontype { '15' }
    cmteid { 'C00027466' }
    gender { 'M' }
    microfilm { '11020480483' }
    occupation { 'HEDGE FUND MANAGER' }
    employer { 'THIRD POINT LLC' }
    fec_cycle_id { '2012_1120620120011115314' }
  end

  factory :loeb_donation_two, class: OsDonation do
    cycle { '2010' }
    fectransid { '1050220110005750383' }
    contribid { 'U00000038301' }
    contrib { "LOEB, DANIEL MR" }
    recipid { "C00027466" }
    orgname { "Third Point LLC" }
    realcode { "F2700" }
    date { '2010-09-17' }
    amount { 50000 }
    city { "NEW YORK" }
    state { "NY" }
    zip { '10022' }
    recipcode { 'RP' }
    transactiontype { '15' }
    cmteid { 'C00027466' }
    gender { 'M' }
    microfilm { '10020853341' }
    occupation { 'HEDGE FUND MANAGER' }
    employer { 'THIRD POINT LLC' }
    fec_cycle_id { '2010_1050220110005750383' }
  end

  factory :loeb_ref_one, class: Reference do
    name { "FEC Filing 11020480483" }
    source  { "http://images.nictusa.com/cgi-bin/fecimg/?11020480483" }
    object_model { "Relationship" }
    # object_id 419156
  end

  factory :loeb_ref_two, class: Reference do
    name { "FEC Filing 10020853341" }
    source { "http//images.nictusa.com/cgi-bin/fecimg/?10020853341" }
    object_model { "Relationship" }
    # object_id 419156
  end

  factory :loeb_ref_three, class: Reference do
    name { "FEC contribution search" }
    source { "http://docquery.fec.gov/cgi-bin/qindcont/1/(lname|MATCHES|:LOEB:)|AND|(fname|MATCHES|:DANIEL*:)" }
    object_model { "Relationship" }
    # object_id 419156
  end

  factory :loeb_ref_four, class: Reference do
    name { "FEC Filing" }
    source { "http//images.nictusa.com/cgi-bin/fecimg/?10020853341" }
    object_model { "Relationship" }
    # object_id 419156
  end

  factory :loeb_donation_model, class: Donation do
    bundler_id { nil }
    relationship_id { 419156 }
  end

end
