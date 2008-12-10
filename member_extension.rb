# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class MemberExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/member"
  
  define_routes do |map|
    map.resources :members, :path_prefix => '/admin', :controller  => 'admin/members', :collection => {:auto_complete_for_member_company => :any}
    map.resource :session
    map.activate '/activate', :controller => 'sessions', :action => 'activate'
  end
  
  def activate
    WillPaginate.enable_named_scope
    admin.tabs.add "Members", "/admin/members", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Member"
  end
  
end