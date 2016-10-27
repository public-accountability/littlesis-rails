class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    @url = 'https://littlesis.com/login'
    mail(to: @user.email, subject: 'Welcome to LittleSis!')
  end

end
