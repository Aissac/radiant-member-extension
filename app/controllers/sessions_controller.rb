class SessionsController < ApplicationController

  include AuthenticatedMembersSystem
  
  skip_before_filter :verify_authenticity_token
  
  # def create
  #   member = Member.authenticate(params[:email], params[:password])
  #   if member
  #     self.current_member = member
  #     redirect_to "/"
  #     flash[:notice] = "Logged in successfully"
  #   else
  #     @login = params[:login]
  #     flash.now[:error]  = "Login failed"
  #     render :action => 'new'
  #   end
  # end
  
  def create
    logout_keeping_session!
    member = Member.authenticate(params[:email], params[:password])
    if member
      self.current_member = member
      new_cookie_flag = (params[:member_remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end
  
  def activate
    member = Member.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && member && !member.active?
      member.activate
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to new_session_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_to "/"
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_to "/"
    end
  end
  
end