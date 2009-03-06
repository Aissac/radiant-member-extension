Radiant Member Extension
===

About
---

An extension by [Aissac][aissac] that adds members support to the [Radiant CMS][radiant]. Using this extension you can restrict access to radiant pages only for members. It is based on Restful Authentication System, so the member model has almost the same attributes. The members can be added or edited only from Radiant Admin.

The Member Extension is Radiant 0.7.1 compatible.

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

    rake radiant:extensions:member:migrate
    rake radiant:extensions:member:update

Configuration
---

If you are using Radiant 0.7 or newer, you can place this configuration in `config/initializers/member.rb` of your project:

    MEMBER_LOGIN_PATH = '/members' # The URL for the login form of your website.
    MEMBER_HOME_PATH = '/articles' # Default home for logged in members.
    MEMBERS_ROOT = 'articles'      # Everything under this path requires member login.
                                   # Notice the lack of leading and trailing slashes.

    REST_AUTH_SITE_KEY = '<some big secret key here>'
    REST_AUTH_DIGEST_STRETCHES = 10

For installations of Radiant 0.6.9 or older this configuration goes into `environment.rb`.

For security purposes you must define `REST_AUTH_SITE_KEY` and `REST_AUTH_DIGEST_STRETCHES`. This is based on the Restful Authentication.

Also, because we use `action_mailer` to send emails to the members you should comment the ` # config.frameworks -= [ :action_mailer ]` in your `environment.rb` file.

Usage
---

### Site integration

You need to create a page in your site where members can log in. The URL for this page must be the one specified by `MEMBER_LOGIN_PATH`.

The form field names must match the following:

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

    <a href="/members">Login</a><!-- This links to the MEMBER_LOGIN_PATH configuration parameter. -->
    <a href="/logout">Logout</a>
    
### Cookie flash

TODO

### Administration

Member extension a tab to the Radiant admin interface to let you add and update members. You can choose to reset a member's password and email them the new password.

TODO
---

* Styling of admin interface and more user friendlyness.
* Import member list from CSV/XLS.
* Rake task to send out emails with 
* Delete/Disable members.
* Tags for URLs: members home, login/logout pages.

Contributors
---

[aissac]: http://aissac.ro
[radiant]: http://radiantcms.org/