module Devise
  module Strategies
    class LegacyPassword < Authenticatable
      def authenticate!
        user = User.find_by_email(params['user']['email'])
        if params['user'].nil? || params['user']['email'].nil? || params['user']['password'].nil?
          pass # skip authenticate if params aren't provided 
        elsif user.encrypted_password.present?
          Rails.logger.info "Skipping Legacy Password"
          pass
        else
          Rails.logger.info "Using Legacy Password"
          if user.legacy_check_password(params['user']['password'])
            remember_me(user)
            success!(user)
          else
            fail!
          end
        end
      end
    end
  end
end
