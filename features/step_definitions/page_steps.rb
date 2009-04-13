Given /^login and member home pages exist$/ do
  home_page = Page.find_by_parent_id(nil)
  
  title = "Members Login"
  page = Page.create!(
     :parent => home_page,
     :title => title,
     :breadcrumb => title,
     :slug => 'login',
     :status => Status[:published],
     :published_at => Time.now.to_s(:db)
   )

  page.parts.create! :name => 'body', :content => %Q{
    <h2>Log in</h2>
    <form action="<r:member:sessions />" method="post">
      <p><label>Email</label><br />
      <input id="email" name="email" type="text" /></p>
      <p><label>Password</label><br/>
      <input id="password" name="password" type="password" /></p>
      <p><label for="remember_me">Remember me</label><br />
      <input id="remember_me" name="remember_me" type="checkbox" value="1" /></p>
      <p><input name="commit" type="submit" value="Log in" /></p>
    </form>
  }
  
  title = "Members home"
  page = Page.create!(
      :parent => home_page,
      :title => title,
      :breadcrumb => title,
      :slug => 'members',
      :status => Status[:published],
      :published_at => Time.now.to_s(:db)
  )
  
  page.parts.create! :name => 'body', :content => %Q{
    Welcome to the members home!
  }
end
