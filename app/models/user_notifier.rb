class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://ecttest:8080/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://ecttest:8080/"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "sanuras@expedia.com"
    @subject     = "[TestCaseManager] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
