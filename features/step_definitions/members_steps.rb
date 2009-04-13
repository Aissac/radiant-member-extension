Given /^a registered member "([^\"]*)" with password "([^\"]*)"$/ do |name, pass|
  Factory.create(:member, :name => name, :password => pass, :password_confirmation => pass)
end