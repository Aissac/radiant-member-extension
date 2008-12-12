class SessionsController < ApplicationController

  include AuthenticatedMembersSystem
  
  no_login_required
  # skip_before_filter :verify_authenticity_token
  
  def new
  end

  def create
    logout_keeping_member_session!
    member = Member.authenticate(params[:email], params[:password])
    if member
      self.current_member = member
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_member_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
      logger.debug(">>>>>>>>>>>>>> session_controller Member ID #{member.id} si CurrentMember ID #{current_member.id}")
      logger.debug(">>>>>>>>>>>>>>>session_controller session_member_id #{session[:member_id]}")
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_member_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected
    # Track failed login attempts
    def note_failed_signin
      flash[:error] = "Couldn't log you in as '#{params[:email]}'"
      logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
    end
  
end