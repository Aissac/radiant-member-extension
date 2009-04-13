class MemberSessionsController < ApplicationController

  include AuthenticatedMembersSystem
  
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  use_cookies_flash
  
  def new
  end

  def create
    logout_keeping_member_session!
    member = Member.authenticate(params[:email], params[:password])
    if member
      self.current_member = member
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_member_cookie! new_cookie_flag
      note_succesful_login
      redirect_back_or_default(MemberExtensionSettings.home_path)
    else
      note_failed_login
      @email       = params[:email]
      @remember_me = params[:remember_me]
      redirect_to MemberExtensionSettings.login_path
    end
  end

  def destroy
    logout_keeping_member_session!
    note_succesful_logout
    redirect_back_or_default MemberExtensionSettings.login_path
  end
  
  protected
  
    def note_failed_login(config = Radiant::Config)
      config["Member.failed_login"].blank? ? flash[:error] = "Couldn't log you in as '#{params[:email]}'." : flash[:error] = config["Member.failed_login"]
      logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
    end

    def note_succesful_login(config = Radiant::Config)
      config["Member.succesful_login"].blank? ? flash[:notice] = "Logged in successfully." : flash[:notice] = config["Member.succesful_login"]
    end

    def note_succesful_logout(config = Radiant::Config)
      config["Member.succesful_logout"].blank? ? flash[:notice] = "You have been logged out." : flash[:notice] = config["Member.succesful_logout"]
    end
end