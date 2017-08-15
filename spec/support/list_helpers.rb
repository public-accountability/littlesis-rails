module ListHelpers
  # probably will be helpful at some point: https://stackoverflow.com/questions/10861322/repeating-rspec-example-groups-with-different-arguments/10861610#10861610
  def sign_in_and_get(user)
    before do
      sign_in user if user.present?
      get :members, id: '123'
    end
    yield
  end

  def check_users(users, response)
    users.each do |(name, user)|
      context "#{name}" do
        sign_in_and_get user do
          it { should respond_with(response) }
        end
      end
    end
  end
  
end
