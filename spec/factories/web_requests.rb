FactoryBot.define do
  factory :web_request do
    remote_address { Faker::Internet.ip_v4_address }
    time { Time.zone.now }
    host { 'littlesis.org' }
    http_method { 'GET' }
    uri { '/' }
    status { 200 }
    body_bytes { rand(8..100_000) }
    request_time { 0.5 }
    user_agent { Faker::Internet.user_agent }
    request_id { SecureRandom.hex }
  end
end
