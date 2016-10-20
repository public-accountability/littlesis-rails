Warden::Strategies.add(:rails_auth) do 
  def valid? 
    # code here to check whether to try and authenticate using this strategy; 
    # return (params['user']['email'].present? and params['user']['password'].present?)
    return true
  end 

  def authenticate! 
    # code here for doing authentication;
    if params['user'].nil? || params['user']['email'].nil? || params['user']['password'].nil?
      Rails.logger.info "Skipping Rails Auth"
      pass # skip authenticate if params aren't provided 
    else
      user = User.find_by_email(params['user']['email'])
      sf_user = user.sf_guard_user
      unless sf_user.nil?
        if Digest::SHA1.hexdigest(sf_user.salt + params['user']['password']) == sf_user.password
          Rails.logger.info "Whoohoo!"
          success!(user)
        end
      end
    end
  end 
end 
