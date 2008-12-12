class MemberMailer < ActionMailer::Base
  def password_email(member)
    setup_email(member)
    @subject    += ' - Please activate your new account'
  
    @body[:member]  = member
  end
  
  protected
    def setup_email(member)
      @recipients  = "#{member.email}"
      @from        = "no_reply@site.ro"
      @subject     = "www.site.ro"
      @sent_on     = Time.now
      @body[:member] = member
    end
end
