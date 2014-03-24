class StudentDebtMailer < ActionMailer::Base
  default( 
    from: "LittleSis Research <#{Lilsis::Application.config.research_from_email}>", 
  )

  def welcome(signup)
    @name = signup.first_name
    
    mail(to: signup.email, subject: "Welcome to Wall Street Higher Ed Watch")
  end
end
