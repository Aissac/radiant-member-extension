Radiant Member Extension
===

About
---

An extension by [Aissac][aissac] that adds members support to the [Radiant CMS][radiant]. Using this extension you can restrict access to radiant pages only for members. It is based on Restfull Authentication System, so the member model has almost the same attributes. The members can be added or edited only from Radiant Admin.

The Member Extension is Radiant 0.7.1 compatible. ???

Installation
---

Member Extension has two dependencies, the auto\_complete plugin:

    git submodule add git://github.com/rails/auto_complete.git vendor/plugins/auto_complete
    
And the will\_paginate gem/plugin:

    git submodule add git://github.com/mislav/will_paginate.git vendor/plugins/will_paginate
    
or

    sudo gem install mislav-will_paginate

Install the Member Extension:
    
    git submodule add add git://github.com/aissac/member.git vendor/extensions/member
    
Then run the rake tasks:

    rake [ENV] radiant:extensions:member:migrate
    rake [ENV] radiant:extensions:member:update.

The next step is to .....

    MEMBER_LOGIN_PATH = '/members' # this is the Radiant page where you have the login form .
    MEMBER_HOME_PATH = '/articles' # this is where the member will be redirected after login.
    MEMBERS_ROOT = 'articles' # all the pages under this node can be accessed only by members.
    
Because Member Extension tries to copy the Restfull Authentication system, for additional protection of your application you have to create a `initializers/site_key.rb` file in your `config` folder. In this file set the `REST_AUTH_SITE_KEY` to some unussual string and the `REST_AUTH_DIGEST_STRETCHES` key to an integer value, like below

    REST_AUTH_SITE_KEY = 'f7c8cdc38ec686f6b9086013f7adda660d641106'
    REST_AUTH_DIGEST_STRETCHES = 10

Also, because we use `action_mailer` to send emails to the members you should comment the ` # config.frameworks -= [ :action_mailer ]` in your environment file.

Usage
---

Members extension provides you with a page where you can administer your members. Only a site admin can add or edit members. The admin can also reset a member\'s password, action which will send an email with the new password.

### Working example

Login form:

    <h2>Log in</h2>
    <form action="/member_sessions" method="post">
      <p><label>Email</label><br />
      <input id="email" name="email" type="text" /></p>
      <p><label>Password</label><br/>
      <input id="password" name="password" type="password" /></p>
      <p><label for="remember_me">Remember me</label><br />
      <input id="remember_me" name="remember_me" type="checkbox" value="1" /></p>
      <p><input name="commit" type="submit" value="Log in" /></p>
    </form>

Session links:

    <a href="/members">Login</a>
    <a href="/logout">Logout</a>

TODO
---

Delete/Disable members

Contributors
---

[aissac]: http://aissac.ro
[radiant]: http://radiantcms.org/