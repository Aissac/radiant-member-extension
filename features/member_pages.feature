Feature: Authenticating members
      As a member
    I want to sign in
  In order to access restricted pages
  
  Scenario: Signing in successfully
    Given I go to the login page
      And I fill in "email" with "bob@example.com"
      And I fill in "password" with "secret"
      And I press "Log in"
     Then I should be on the members homepage
      And I should see "Welcome to the members home!"
  
  Scenario: Failing login
     When I go to the login page
      And I fill in "email" with "bob@example.com"
      And I fill in "password" with "bad secret"
      And I press "Log in"
     Then I should be on the login page
      And I should not see "Welcome to the members home!"