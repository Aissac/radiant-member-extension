Given /^I am logged in as admin$/ do
  Given "I go to to \"the welcome page\""
   When "I fill in \"Username\" with \"admin\""
   When "I fill in \"Password\" with \"password\""
   When "I press \"Login\""
end

Given /^I fill in name, email and company with "([^\"]*)", "([^\"]*)" and "([^\"]*)"$/ do |name, email, company|
  When "I fill in \"Name\" with \"#{name}\""
  When "I fill in \"Email\" with \"#{email}\""
  When "I fill in \"Company\" with \"#{company}\""
end

Given /^the login with "([^\"]*)" and "([^\"]*)" should be successful$/ do |email, password|
  Given "I go to the login page"
   When "I fill in \"email\" with \"#{email}\""
   When "I fill in \"password\" with \"#{password}\""
   When "I press \"Log in\""
   Then "I should be on the members homepage"
   Then "I should see \"Welcome to the members home!\""
end

Given /^the login with "([^\"]*)" and "([^\"]*)" should fail$/ do |email, password|
  Given "I go to the login page"
   When "I fill in \"email\" with \"#{email}\""
   When "I fill in \"password\" with \"#{password}\""
   When "I press \"Log in\""
   Then "I should be on the login page"
   Then "I should not see \"Welcome to the members home!\""
end

When /^I fill in "([^\"]*)" with the valid csv file$/ do |field|
  fill_in(field, :with => RAILS_ROOT + "/vendor/extensions/member/features/fixtures/members_valid.csv") 
end

When /^I fill in "([^\"]*)" with the invalid csv file$/ do |field|
  fill_in(field, :with => RAILS_ROOT + "/vendor/extensions/member/features/fixtures/members_invalid.csv") 
end