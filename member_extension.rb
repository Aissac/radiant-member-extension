# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class MemberExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/member"
  
  define_routes do |map|
    map.resources :members, :path_prefix => '/admin', :controller  => 'admin/members', :collection => {:auto_complete_for_member_company => :any}
    map.resources :member_sessions
    map.reset_password '/admin/members/:id/reset_password', :controller => 'admin/members', :action => 'reset_password'
    map.send_email '/admin/members/:id/send_email', :controller => 'admin/members', :action => 'send_email'
    map.member_logout '/logout', :controller => 'member_sessions', :action => 'destroy'
    
  end
  
  def activate
    WillPaginate.enable_named_scope
    admin.tabs.add "Members", "/admin/members", :after => "Layouts", :visibility => [:all]
    ApplicationController.send(:include, ApplicationControllerMemberExtensions)
    SiteController.class_eval do
      include AuthenticatedMembersSystem
      include SiteControllerMemberExtensions
    end
  end
  
  def deactivate
    admin.tabs.remove "Member"
  end
  
end