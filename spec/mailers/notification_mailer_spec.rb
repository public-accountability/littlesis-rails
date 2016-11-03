require "rails_helper"

describe NotificationMailer, type: :mailer do
  describe '#contact_email' do 
    before(:each) do 
      @params = {name: 'me', email: 'email@email.com', message: 'hey', subject: 'hi'}
      @mail = NotificationMailer.contact_email(@params)
    end
    
    it 'has correct subject' do 
      expect(@mail.subject).to eql 'Contact Us: hi'
    end

    it 'has correct to' do 
      expect(@mail.to).to eq [APP_CONFIG['notification_to']]
    end
    
    it 'has correct from' do 
      expect(@mail.from).to eq [APP_CONFIG['notification_email']]
    end

    it 'has correct reply_to' do 
      expect(@mail.reply_to).to eq [@params[:email]]
    end

    it 'has message' do 
      expect(@mail.encoded).to include(@params[:message])
    end

    it 'sends email' do 
      expect { @mail.deliver_now }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email later' do 
      ActiveJob::Base.queue_adapter = :test
      expect { @mail.deliver_later }
        .to have_enqueued_job.on_queue('mailers')
    end

  end
end
