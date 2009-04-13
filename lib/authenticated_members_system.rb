module AuthenticatedMembersSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def member_logged_in?
      !!current_member
    end

    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_member
      @current_member ||= (member_login_from_session || member_login_from_basic_auth || member_login_from_cookie) unless @current_member == false
    end

    # Store the given user id in the session.
    def current_member=(new_member)
      session[:member_id] = new_member ? new_member.id : nil
      @current_member = new_member || false
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    #
    def member_authorized?(action = action_name, resource = nil)
      member_logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def member_login_required
      member_authorized? || member_access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def member_access_denied
      respond_to do |format|
        format.html do
          member_store_location
          redirect_to MemberExtensionSettings.member_defaults[:member_login_path]
        end
        # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
        # Add any other API formats here.  (Some browsers, notably IE6, send Accept: */* and trigger 
        # the 'format.any' block incorrectly. See http://bit.ly/ie6_borken or http://bit.ly/ie6_borken2
        # for a workaround.)
        format.any(:json, :xml) do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def member_store_location
      session[:member_return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.  Set an appropriately modified
    #   after_filter :store_location, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirect_back_or_default(default)
      redirect_to(session[:member_return_to] || default)
      session[:member_return_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_member, :member_logged_in?, :member_authorized? if base.respond_to? :helper_method
    end

    #
    # Login
    #

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def member_login_from_session
      self.current_member = Member.find_by_id(session[:member_id]) if session[:member_id]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def member_login_from_basic_auth
      authenticate_with_http_basic do |email, password|
        self.current_member = Member.authenticate(email, password)
      end
    end
    
    #
    # Logout
    #

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
    def member_login_from_cookie
      member = cookies[:member_auth_token] && Member.find_by_remember_token(cookies[:member_auth_token])
      if member && member.remember_token?
        self.current_member = member
        handle_remember_member_cookie! false # freshen cookie token (keeping date)
        self.current_member
      end
    end

    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on login.
    # However, **all session state variables should be unset here**.
    def logout_keeping_member_session!
      # Kill server-side auth cookie
      @current_member.forget_me if @current_member.is_a? Member
      @current_member = false     # not logged in, and don't do it for me
      kill_remember_member_cookie!     # Kill client-side auth cookie
      session[:member_id] = nil   # keeps the session but kill our variable
      # explicitly kill any other session variables you set
    end

    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (logged-out to logged-in).
    def logout_killing_member_session!
      logout_keeping_member_session!
      reset_session
    end
    
    #
    # Remember_me Tokens
    #
    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login

    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login

    def valid_remember_member_cookie?
      return nil unless @current_member
      (@current_member.remember_token?) && 
        (cookies[:member_auth_token] == @current_member.remember_token)
    end
    
    # Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_member_cookie!(new_cookie_flag)
      return unless @current_member
      case
      when valid_remember_member_cookie? then @current_member.refresh_token # keeping same expiry date
      when new_cookie_flag        then @current_member.remember_me 
      else                             @current_member.forget_me
      end
      send_remember_member_cookie!
    end
  
    def kill_remember_member_cookie!
      cookies.delete :member_auth_token
    end
    
    def send_remember_member_cookie!
      cookies[:member_auth_token] = {
        :value   => @current_member.remember_token,
        :expires => @current_member.remember_token_expires_at }
    end
end
