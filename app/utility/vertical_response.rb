require 'soap/wsdlDriver'  
require "date"

class VerticalResponse
  attr_accessor :session_id

  def initialize
    ensure_session
  end

  def ensure_session
    @session_id ||= create_session_id
  end

  def create_session_id
    wsdl = 'https://api.verticalresponse.com/partner-wsdl/1.0/VRAPI.wsdl'  
    @vr = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

    username = Lilsis::Application.config.verticalresponse_username
    password = Lilsis::Application.config.verticalresponse_password
    session_time = 4

    session_id = @vr.login({
      'username' => username,
      'password' => password,
      'session_duration_minutes' => session_time
    })
  end

  def add_list_member(list_id, member_data)
    member_record = @vr.addListMember({
      'session_id' => @session_id,
      'list_member' => {
        'list_id' => list_id,
        'member_data' => member_data,                                
        }
      }
    )
  end
end