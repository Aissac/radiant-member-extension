module MemberTags
  
  include Radiant::Taggable
  
  tag 'member' do |tag|
    tag.expand
  end
  
  desc %{
    Renders the login link taking into acount the @member_login_path@ setting from Radiant::Config. Use the @text@ attribute to control the text in the link. The default is "Login".
    
    *Usage*:
    <pre><code><r:member:login [text="Come on in!"] /></code></pre>
  }
  tag 'member:login' do |tag|
    text = tag.attr['text'] || 'Login'
    %{<a href="#{MemberExtensionSettings.login_path}">#{text}</a>}
  end
  
  desc %{
    Renders the logout link. Use the @text@ attribute to control the text in the link. The default is "Logout".
    
    *Usage*:
    <pre><code><r:member:logout [text="Get out!"] /></code></pre>
  }
  tag 'member:logout' do |tag|
    text = tag.attr['text'] || 'Logout'
    %{<a href="#{MemberExtensionSettings.defaults[:logout_path]}">#{text}</a>}
  end
  
  desc %{
    Renders the link where the member will be redirected after logging in, taking into acount the @member_home_path@ setting from Radiant::Config. Use the @text@ attribute to control the text in the link. The default is "Members Home".
    
    *Usage*:
    <pre><code><r:member:home [text="Members Home!"] /></code></pre>
  }
  tag 'member:home' do |tag|
    text = tag.attr['text'] || 'Members Home'
    %{<a href="#{MemberExtensionSettings.home_path}">#{text}</a>}
  end
  
  desc %{
    Renders the link to the node under which the pages will be restricted, taking into acount the @member_root@ setting from Radiant::Config. Use the @text@ attribute to control the text in the link. The default is "Members Home".
    
    *Usage*:
    <pre><code><r:member:root [text="Members Root!"] /></code></pre>
  }
  tag 'member:root' do |tag|
    text = tag.attr['text'] || 'Root'
    %{<a href="#{MemberExtensionSettings.root_path}">#{text}</a>}
  end
  
  desc %{
    Use this tag as action for the login form.
    
    *Usage*:
    <pre><code><r:member:sessions /></code></pre>
  }
  tag 'member:sessions' do |tag|
    "#{MemberExtensionSettings.defaults[:sessions_path]}"
  end
end