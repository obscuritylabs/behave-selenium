from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from elementium.drivers.se import SeElements

import os

def before_all(context):
    chrome_options = Options()
    chrome_options.add_argument("headless")
    chrome_options.add_argument("no-sandbox")
    chrome_options.add_argument("window-size=1920,1080")
    chrome_options.add_argument("disable-setuid-sandbox")

    remote = os.getenv("BEHAVE_RUN_LOCAL") == "true"

    if (remote):
      context.driver = SeElements(
        webdriver.Remote(
          command_executor='http://host.docker.internal:9515/wd/hub'
        )
      )
    else:
      context.driver = SeElements(
        webdriver.Chrome(
          chrome_options=chrome_options
        )
      )

def after_all(context):
    context.driver.browser.quit()
