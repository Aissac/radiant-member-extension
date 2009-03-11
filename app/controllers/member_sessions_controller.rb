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
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default(MEMBER_HOME_PATH)
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      redirect_to MEMBER_LOGIN_PATH
    end
  end

  def destroy
    logout_keeping_member_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(MEMBER_LOGIN_PATH)
  end

  protected
  
    # Track failed login attempts
    def note_failed_signin
      flash[:error] = "Couldn't log you in as '#{params[:email]}'"
      logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
    end
  
end