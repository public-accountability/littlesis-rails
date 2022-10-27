# frozen_string_literal: true

# Communicates with our powerbase instance
# https://littlesis.ourpowerbase.net/civicrm/api4
module Powerbase
  HOST = "littlesis.ourpowerbase.net"
  BASE = "/civicrm/ajax/api4"

  module Client
    def self.create_contact(email, name: '')
      post "/Contact/create",
           {
             'values' => {
               'contact_type' => 'Individual',
               'name' => name
             },
             'chain' => {
               'create_email' => [
                 'Email',
                 'create',
                 { 'values' => { 'contact_id' => '$id', 'email': email } }
               ]
             }
           }
    end

    def self.get_contact(email_address)
      post "/Contact/get",
           {
             'select' => ['email', 'id', 'contact_type'],
             'join' => [['Email AS email', 'INNER']],
             'where' => [['email.email', '=', email_address]],
             'limit' => 1
           }
    end

    def self.post(path, params)
      Net::HTTP.start(HOST, 443, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(BASE + path)
        request.set_form_data("params" => JSON.dump(params))
        request['X-Civi-Auth'] = "Bearer #{Rails.application.config.littlesis.powerbase_api_key}"
        response = http.request(request)
        if response.is_a? Net::HTTPSuccess
          JSON.parse(response.body)
        else
          raise Exceptions::HTTPRequestFailedError, "Request to #{path} failed with code #{response.code}\nBody: #{response.body}"
        end
      end
    end
  end

  # Powerbase User - connected via email address
  class User
    attr_reader :email

    #  user = Powerbase::User.new("example@littlesis.org")
    def initialize(email)
      @email = email
    end

    # Creates powerbase contact for the email address
    def create
      if contact.nil?
        Client.create_contact(@email)
      end
    end

    # Retrieves existing contact information
    def contact
      @contact ||= Client.get_contact(@email)['values'].first
    end

    def do_not_email
    end

    def permit_emailing
    end

    # adds user to the group
    def add_to(group)
    end

    # removes user from the gruop
    def remove_from(group)
    end
  end
end
