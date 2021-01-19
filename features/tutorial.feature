Feature: Testing Behave

Scenario: Test Googling
  Given I go to Google
  When I search for "Obscurity Labs"
  Then I should see the first link is "https://obscuritylabs.com/"
