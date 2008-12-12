module SiteControllerExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      session :disabled => false
      alias_method_chain :show_page, :member_validation
    end
  end
  
  module InstanceMethods
    def show_page_with_member_validation
      url = params[:url]
      if Array === url
        url = url.join('/')
      else
        url = url.to_s
      end
      logger.debug(">>>> session: #{session.inspect}")
      logger.debug(">>>>>>>>>>>> site_controller current_member: #{current_member}")
      logger.debug(">>>>>>>>>>>> site_controller session_member: #{session[:member_id]}")
      if MemberSystem.allow_url?(current_member, url)
        show_page_without_member_validation
      else
        flash[:error] = "Member must be logged in."
        redirect_to new_session_url
      end
    end
  end
end