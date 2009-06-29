Feature: Managing Members
  In order to manipulate members
  As an admin
  I want to create, update, delete, activate and deactivate, and import members

  Background:
    Given I am logged in as admin
     When I follow "Members"

  Scenario: Creating an inactive member
    Given I follow "Add member"
     When I fill in name, email and company with "Cristi", "cristi@aissac.ro" and "Aissac"
     When I press "Sign up"
     Then I should see "Account created."
      And I should see "Cristi"
      And I should see "Activate"
      And the login with "cristi@aissac.ro" and "secret" should fail
      
  Scenario: Creating an active member
    Given I follow "Add member"
     When I fill in name, email and company with "Cristi", "cristi@aissac.ro" and "Aissac"
      And I fill in "Password" with "secret"
      And I fill in "Password Again" with "secret"
     When I press "Sign up"
     Then I should see "Account created."
      And I should see "Cristi"
      And I should see "Deactivate"
      And the login with "cristi@aissac.ro" and "secret" should be successful
      
  Scenario: Updating a member
    Given I follow "Edit"
      And I fill in "email" with "the_new_bob@example.com"
      And I press "Update"
     Then I should see "Account edited."
      And I should see "the_new_bob@example.com"
      And the login with "the_new_bob@example.com" and "secret" should be successful
      
  Scenario: Deleting a member
    Given I follow "Delete"
     Then I should see "Member deleted!"
      And I should not see "Bob Dylan"
      And the login with "bob@example.com" and "secret" should fail
  
  Scenario: Activating a member
    Given I follow "Add member"
     When I fill in name, email and company with "Cristi", "cristi@aissac.ro" and "Aissac"
     When I press "Sign up"
     Then I should see "Account created."
      And I should see "Cristi"
      And I should see "Activate"
      
     When I follow "Activate"
     Then I should see "Member Cristi has been activated!"
     Then "cristi@aissac.ro" should receive 1 email
      And "cristi@aissac.ro" should have 1 email
      And I should not see "Activate"
    
  Scenario: Deactivating a member
    Given I follow "Deactivate"
     Then I should see "Member Bob Dylan has been deactivated!"
      And I should not see "Deactivate"
      And the login with "bob@example.com" and "secret" should fail

  Scenario: Reseting a user's password
    Given I follow "reset password"
     When I press "Yes"
     Then I should see "The password for Bob Dylan was reset and sent via email."
      And "bob@example.com" should receive 1 email
      And "bob@example.com" should have 1 emails

  Scenario: Importing members
    Given I follow "Import members from CSV file"
     When I fill in "Choose a CSV file" with the valid csv file
      And I press "Import data"
     Then I should see "Imported 2 members. 0 members were duplicate."
  
  Scenario: Importing and updating members
    Given I follow "Import members from CSV file"
     When I fill in "Choose a CSV file" with the invalid csv file
      And I press "Import data"
     Then I should see "Imported 0 members. 0 members were duplicate."
     When I fill in "member__email" with "good_email@example.com"
      And I press "Add members"
     Then I should see "Imported 1 members."
      And I should see "good_email@example.com"