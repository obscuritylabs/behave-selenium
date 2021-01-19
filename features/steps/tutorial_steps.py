from behave import given, when, then
from selenium.webdriver.common.keys import Keys

@given('I go to Google')
def step(context):
  context.driver.navigate('https://www.google.com')
  context.driver.set_window_size("1920", "1080")

@when('I search for "{text}"')
def enter_name(context, text):
  context.driver.find("[name='q']", wait=True).write(text).write(Keys.RETURN)

@then('I should see the first link is "{url}"')
def see_search_results(context, url):
  context.driver.find('#rso', wait=True).find('a', wait=True).get(0) \
                .insist(lambda e: e.attribute("href") == url, ttl=10)