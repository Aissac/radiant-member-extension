# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'

class MemberExtension < Radiant::Extension
  version "0.5"
  description "Restrict site content to registered members."
  url "http://blog.aissac.ro/radiant/member-extension"
  
  define_routes do |map|
    map.resources :members, 
      :path_prefix => '/admin', 
      :controller  => 'admin/members', 
      :collection => { 
        :auto_complete_for_member_company => :any,
        :import => :get,
        :import_from_csv => :post,
        :edit_invalid => :get,
        :update_invalid => :post },
      :member => {
        :reset_password => :get,
        :send_email => :post,
        :activate => :post,
        :deactivate => :post
      }
    map.resources :member_sessions, :as => MemberExtensionSettings.sessions_path
    map.member_logout MemberExtensionSettings.logout_path, :controller => 'member_sessions', :action => 'destroy'
  end
  
  def activate
    if RAILS_ENV == 'production'
      MemberExtensionSettings.check!
    end
    admin.nav["settings"] << admin.nav_item(:members, "Members", "/admin/members")
    ApplicationController.send(:include, ApplicationControllerMemberExtensions)
    SiteController.class_eval do
      include AuthenticatedMembersSystem
      include SiteControllerMemberExtensions
    end
    Page.class_eval {
      include MemberTags
    }
  end
  
  def deactivate
  end
end