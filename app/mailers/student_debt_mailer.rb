class StudentDebtMailer < ActionMailer::Base
  default( 
    from: "LittleSis Research <#{Lilsis::Application.config.research_from_email}>", 
    host: 'littlesis.org'
  )

  def welcome(signup)
    @name = signup.first_name

    mail(to: signup.email, subject: "Welcome to Wall Street Higher Ed Watch")
  end
end
