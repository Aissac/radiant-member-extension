class MemberPagesDataset < Dataset::Base
  uses :pages
  def load    
    create_page "Members Login", :slug => "login", :body => %Q{
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
      
    create_page "Members Home", :slug => "members", :body => %Q{
      Welcome to the members home!
    }
  end
end