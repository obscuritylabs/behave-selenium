from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from elementium.drivers.se import SeElements
from configparser import ConfigParser
import os

def before_all(context):
    config = ConfigParser()
    config_file = (os.path.join(os.getcwd(), 'setup.cfg'))
    config.read(config_file)

    browser = config.get('Environment', 'Browser')
    remote = config.get('Environment', 'Local')

    if (remote == "true"):
      if (browser == "chrome"):
        context.driver = SeElements(
          webdriver.Remote(
            command_executor='http://host.docker.internal:9515/wd/hub'
          )
        )
      elif (browser == "firefox"):
        context.driver = SeElements(
          webdriver.Remote(
            command_executor='http://host.docker.internal:4444'
          )
        )
    else:
      if (browser == "chrome"):
        chrome_options = ChromeOptions()
        chrome_options.headless = True
        chrome_options.add_argument("no-sandbox")
        chrome_options.add_argument("disable-setuid-sandbox")
        context.driver = SeElements(
          webdriver.Chrome(
            chrome_options=chrome_options
          )
        )
      elif (browser == "firefox"):
        firefox_options = FirefoxOptions()
        firefox_options.headless = True
        context.driver = SeElements(
          webdriver.Firefox(
            firefox_options=firefox_options
          )
        )    

def after_all(context):
    context.driver.browser.quit()
