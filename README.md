Radiant Member Extension
===

About
---

An extension by [Aissac][aissac] that adds members support to [Radiant CMS][radiant]. Using this extension you can restrict access to pages on your public site to be accessible only to members that have an account. It is based on Restful Authentication System, so the member model has almost the same attributes. The members can be added or edited only from Radiant Admin.

The Member Extension is Radiant 0.7.1 compatible.

Features
---

* Restricts access to site pages below a certain path, requiring member login.
* Members can be managed from Radiant Admin. There is *NO* member self-registration.
* Reset and email member's password from Admin interface;
* Bulk import members from a CSV file; fields: name, company, email;
* Radius tags for integrating login/logout functionality into the site;
* Cookie-based flash messages.

Installation
---

Member Extension has two dependencies, the auto\_complete plugin:

    git submodule add git://github.com/rails/auto_complete.git vendor/plugins/auto_complete
    
And the will\_paginate gem/plugin:

    git submodule add git://github.com/mislav/will_paginate.git vendor/plugins/will_paginate
    
or

    sudo gem install mislav-will_paginate --source http://gems.github.com

Install the Member Extension:
    
    git submodule add git://github.com/Aissac/radiant-member-extension.git vendor/extensions/member
    
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

#Available Tags

* See the "available tags" documentation built into the Radiant page admin for more details.
* Use the `<r:member:login />` to render the link for the member login page.
* Use the `<r:member:logout />` to render the link for the logout action.
* Use the `<r:member:home />` to render the link for members home page.
* Use the `<r:member:root />` to render the link for the path that requires member login.
* Use the `<r:member:sessions />` in the login form as action.

### Site integration

You need to create a page in your site where members can log in. The URL for this page must be the one specified by `MEMBER_LOGIN_PATH`.

The form field names must match the following:

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
    
### Cookie flash

Radiant's caching prevents us from using Rails' flash to notify the user of failed login attempts. To work around this, Member Extension uses cookies to store flash messages and Javascript to display them in the view.

In order to use the cookie flash you need to add these Javascript files to your page:

    <script src="/javascripts/prototype.js" type="text/javascript"></script>
    <script src="/javascripts/cookiejar.js" type="text/javascript"></script>
    <script src="/javascripts/member.js" type="text/javascript"></script>
    
`MemberSessionsController` which handles the authentication logic, can assign three flash messages:

When the member logs in successfully we set the `flash[:notice] = "Logged in successfully"`. To see the flash you need to put in the `MEMBER_HOME_PATH` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'notice')
      })
    </script>
    
When there is a failed login we set the `flash[:error] = "Couldn't log you in as Member Email"`. To see the flash you need to put in the `MEMBER_LOGIN_PATH` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'error')
      })
    </script>
    
When the member logs out we set the `flash[:notice] = "You have been logged out."`. To see the flash you need to put in `MEMBER_LOGIN_PATH` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'notice')
      })
    </script>

### Administration

Member extension adds a tab to the Radiant admin interface to let you add and update members. You can choose to reset a member's password and email them the new password.

TODO
---

* Rake task to send out emails.
* Delete/Disable members.
* Use Radiant::Config to store constants (urls, flash messages).

Contributors
---

* Cristi Duma
* Istvan Hoka

[aissac]: http://aissac.ro
[radiant]: http://radiantcms.org/