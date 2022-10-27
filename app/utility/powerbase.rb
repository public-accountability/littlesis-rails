# frozen_string_literal: true

# Communicates with our powerbase instance
# https://littlesis.ourpowerbase.net/civicrm/api4
module Powerbase
  HOST = "littlesis.ourpowerbase.net"
  BASE = "/civicrm/ajax/api4"

  GROUPS = {
    signup: 9,
    tech: 17
  }

  module Client
    def self.create_contact(email, name: '')
      params = { 'values' => {
                   'contact_type' => 'Individual',
                   'name' => name
                 },
                 'chain' => {
                   'create_email' => ['Email', 'create', { 'values' => { 'contact_id' => '$id', 'email': email } }]
                 } }
      Rails.logger.info "requesting new powerbase contact: #{JSON.dump(params)}"
      post "/Contact/create", params
    end

    def self.get_contact(email_address)
      post "/Contact/get",
           {
             'select' => ['email', 'id', 'contact_type', 'display_name', 'do_not_mail'],
             'join' => [['Email AS email', 'INNER']],
             'where' => [['email.email', '=', email_address]],
             'chain' => {
               'groups' => [
                 'GroupContact',
                 'get',
                 { 'where' => [['contact_id', '=', '$id']], 'select' => ['id', 'group_id'] }
               ]
             },
             'limit' => 1
           }
    end

    def self.create_group_contact(group_id:, contact_id:)
      post "/GroupContact/create",
           { 'values' =>  { 'group_id' => group_id, 'contact_id' => contact_id } }
    end

    def self.delete_group_contact(id)
      post "/GroupContact/delete",  { 'where' => [['id', '=', id]] }
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
    attr_reader :record
    extend Forwardable
    def_delegators :@record, :[], :fetch, :dig, :as_json, :to_h, :present?

    #  user = Powerbase::User.new("example@littlesis.org")
    def initialize(email)
      @email = email
      sync
    end

    # Sets @record from powerbase
    def sync
      @record = Client.get_contact(@email)['values'].first
    end

    # Creates powerbase contact for the email address
    def create
      unless present?
        Client.create_contact(@email)
        sync
      end
    end

    def id
      fetch('id')
    end

    def groups
      fetch('groups').map { |g| g['group_id']}
    end

    def do_not_mail?
      fetch("do_not_mail")
    end

    def set_do_not_mail
      raise NotImplementedError
    end

    def cancel_do_not_email
      raise NotImplementedError
    end

    def in?(group)
      groups.include? GROUPS.fetch(group)
    end

    def add_to(group)
      unless in?(group)
        Client.create_group_contact(group_id: GROUPS.fetch(group), contact_id: id)
      end
    end

    def remove_from(group)
      if in?(group)
        group_contact_id = fetch('groups').find { |g| g['group_id'] == GROUPS.fetch(group) }.fetch('id')
        Client.delete_group_contact(group_contact_id)
      end
    end
  end
end
