# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class MemberExtension < Radiant::Extension
  version "0.5"
  description "Restrict site content to registered members."
  url "http://blog.aissac.ro/radiant/member-extension"
  
  define_routes do |map|
    map.resources :members, :path_prefix => '/admin', :controller  => 'admin/members', :collection => {:auto_complete_for_member_company => :any}
    map.resources :member_sessions
    map.member_logout     '/logout',                          :controller => 'member_sessions', :action => 'destroy'
    map.reset_password    '/admin/members/:id/reset_password',:controller => 'admin/members',   :action => 'reset_password'
    map.send_email        '/admin/members/:id/send_email',    :controller => 'admin/members',   :action => 'send_email'
    map.import_members    '/import_members',                  :controller => 'admin/members',   :action => 'import_members'
    map.import_from_csv   '/import_from_csv',                 :controller => 'admin/members',   :action => 'import_from_csv'
    map.edit_members      '/edit_invalid_members',            :controller => 'admin/members',   :action => 'edit_invalid_members'
    map.update_members    '/update_invalid_members',          :controller => 'admin/members',   :action => 'update_invalid_members'
    map.activate          '/admin/members/:id/activate',      :controller => 'admin/members',   :action => 'activate'
    map.deactivate        '/admin/members/:id/deactivate',    :controller => 'admin/members',   :action => 'deactivate'
  end
  
  def activate
    admin.tabs.add "Members", "/admin/members", :after => "Layouts", :visibility => [:all]
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
    admin.tabs.remove "Member"
  end
  
end