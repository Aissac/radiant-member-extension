Radiant Member Extension
===

About
---

An extension by [Aissac][aissac] that adds members support to [Radiant CMS][radiant]. Using this extension you can restrict access to pages on your public site to be accessible only to members that have an account. It is based on Restful Authentication System, so the member model has almost the same attributes. The members can be added or edited only from Radiant Admin.

Tested on Radiant 0.7.1, 0.8 and 0.9 RC1.

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

[Member Extension][rme] has three dependencies, the auto\_complete plugin:

    git clone git://github.com/rails/auto_complete.git vendor/plugins/auto_complete
    
The will\_paginate gem/plugin:

    git clone git://github.com/mislav/will_paginate.git vendor/plugins/will_paginate
    
or

    sudo gem install mislav-will_paginate --source http://gems.github.com
    
And the fastercsv gem:

    sudo gem install fastercsv

Because [Member Extension][rme] keeps the settings in the Radiant::Config table it is highly recommended to install the [Settings Extension][se]

    git clone git://github.com/Squeegy/radiant-settings.git vendor/extensions/settings

Finally, install the [Member Extension][rme]:
    
    git clone git://github.com/Aissac/radiant-member-extension.git vendor/extensions/member
    
Then run the rake tasks:

    rake radiant:extensions:member:migrate
    rake radiant:extensions:member:update

###Note

The git branches hold stable versions of the extension for older version of Radiant CMS. To checkout one of these branches:

    git clone git://github.com/Aissac/radiant-member-extension.git vendor/extensions/member
    cd vendor/extensions/member
    git checkout -b <branch-name> origin/<remote-branch-name>

Configuration
---

### Settings

The [Member Extension][rme] keeps its settings in Radiant::Config table, so in order to use correctly the extension you need to create some settings:

    Radiant::Config['Member.login_value'] = '/members' # The URL for the login form of your website.
    Radiant::Config['Member.home_path'] = '/articles' # Members will be redirected here on successful login.
    Radiant::Config['Member.root_path'] = 'articles' # Everything under this path requires member login.
    
> Notice the lack of leading and trailing slashes.

For controlling the displayed text in the cookie flash (explained below) you can create the following settings:

    Radiant::Config['Member.failed_login'] = 'Couldn't log you in!' # Will be rendered if the user fails to log in.
    Radiant::Config['Member.succesful_login'] = 'Logged in successfully!' # Will be rendered if the user succesfully logs in.
    Radiant::Config['Member.succesful_logout'] = 'You have been logged out!' # Will be rendered if the user succesfully logs out.
    Radiant::Config['Member.need_login'] = 'Member must be logged in!' # Will be rendered if the page needs member access.

If you are using Radiant 0.7 or newer, you can place this configuration in `config/initializers/member.rb` of your project:

    MemberExtensionSettings.defaults[:rest_auth_site_key] = '<some big secret key here>'

The `config/initializers/member.rb` file can be used for member settings, taking into account that the Radiant::Config member settings take precedence.

The settings are created as follows:

    MemberExtensionSettings.defaults[:login_path] = '/login'
    MemberExtensionSettings.defaults[:home_path] = '/home'
    MemberExtensionSettings.defaults[:root_path] = '/root'

> Note: For installations of Radiant 0.6.9 or older, the configuration in `config/initializers/member.rb` goes into `environment.rb`.

### Email

Because we use `action_mailer` to send emails to the members you should comment the ` # config.frameworks -= [ :action_mailer ]` in your `environment.rb` file.

You will probably need to change the Email template. You can find it in `RADIANT_ROOT/vendor/extensions/member/app/views/member_mailer/password_email.erb`. Modify this template at your will, and keep in mind that you have access to the `@member` variable.

Usage
---

###Available Tags

* See the "available tags" documentation built into the Radiant page admin for more details.
* Use the `<r:member:login />` to render the link for the member login page.
* Use the `<r:member:logout />` to render the link for the logout action.
* Use the `<r:member:home />` to render the link for members home page.
* Use the `<r:member:root />` to render the link for the path that requires member login.
* Use the `<r:member:sessions />` in the login form as action.

### Site integration

You need to create a page in your site where members can log in. The URL for this page must be the one specified by `Member.login_path` setting.

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

    <script src="/javascripts/admin/prototype.js" type="text/javascript"></script>
    <script src="/javascripts/cookiejar.js" type="text/javascript"></script>
    <script src="/javascripts/member.js" type="text/javascript"></script>
    
There are four flash messages assigned:

When the member logs in successfully we set the `flash[:notice] = "Logged in successfully"`. To see the flash you need to put in the `Member.home_path` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'notice')
      })
    </script>
    
When there is a failed login we set the `flash[:error] = "Couldn't log you in as Member Email"`. To see the flash you need to put in the `Member.login_path` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'error')
      })
    </script>
    
When the member logs out we set the `flash[:notice] = "You have been logged out."`. To see the flash you need to put in `Member.login_path` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'notice')
      })
    </script>

When some user tries to access a protected page we set the `flash[:notice] = "You must be logged in to access this page."`. To see the flash you need to put in `Member.login_path` page the following snippet:

    <div id="flash" style="display:none"></div>
    <script type="text/javascript">
      document.observe("dom:loaded", function () {
        flash.show('flash', 'error')
      })
    </script>
    
> Note: the above snippet is the same as the one used for the `logout` action. You only need to have this snippet once.

### Activate / Deactivate Members

When you create a new member you have two possibilities: you can leave the password field empty, so the new member will not be active. You will have to manually activate him. The second possibility is to create a password for the new member, making him active. The password will not be sent to him by default on create.

Using the import facility of the extension will create only inactive members.

When you deactivate a member, his password is being copied in a new field and he won't be able to access his acount. Activating him will copy his old password.

### Administration

Member extension adds a tab to the Radiant admin interface to let you add and update members. You can choose to reset a member's password and email them the new password.

TODO
---

* Rake task to send out emails.

Contributors
---

* Cristi Duma ([@cristi_duma][cd])
* Istvan Hoka ([@ihoka][ih])

[aissac]: http://aissac.ro
[radiant]: http://radiantcms.org/
[rme]:http://blog.aissac.ro/radiant/member-extension/
[se]: http://github.com/Squeegy/radiant-settings/tree/master
[cd]: http://twitter.com/cristi_duma
[ih]: http://twitter.com/ihoka