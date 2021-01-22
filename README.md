# Dockerized Behave/Selenium

`behave-selenium` is a docker image for running behave containers. It borrows heavily from William Yeh's [docker-behave](https://github.com/William-Yeh/docker-behave).

## Installed

From python:3.8-slim-buster

| Package              | Version        |
| ---                  | ---            |
| Chrome Driver        | 88.0.4324.27   |
| google-chrome-stable | 88.0.4324.96-1 |
| behave               | 1.2.6          |
| elementium           | 2.0.2          |
| selenium             | 3.141.0        |

## How it works

This container contains [Behave](https://behave.readthedocs.io/en/stable/index.html), (the python version of Cucumber), Selenium, and Elementium. [Elementium](https://github.com/actmd/elementium) is a wrapper for drivers that provides jQuery like syntactic sugar over the regular Selenium bindings, as well as providing fault tolerance.

## How to use

Firstly, add the following to your `features/environment.py` file:

```python
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
```

This will accomodate both headless and local testing.

### Headless

Simply cd into the folder that contains your features folder and run the following:

```bash
docker run --rm -it -v $(pwd):/behave obscuritylabs/behave-selenium
```

If you require additional python packages, you can place a `requirements.txt` file in your steps folder, and it will be installed before running the behave tests. If you would like to place the file in a different location for some reason, you can specify `-e REQUIREMENTS_PATH=path/to/requirements.txt`.

### On local host (for development)

You can have this container run tests on your local browser, which is useful for debugging, and ensuring that tests are running correctly visually. This is where the `BEHAVE_RUN_LOCAL` variable from the environment file comes in.

On Mac, install chromedriver with brew:

```bash
$ brew install chromedriver
```

In order to allow the connection between the container and the local chromedriver, you need to whitelist the IP that is making the connection, and that needs to be specified before the container exists. Otherwise you'll get the error `WebDriverException: Message: Host header or origin header is specified and is not localhost.` In most cases, this will be `172.17.0.2`, specifically if this is the only container running:

```bash
$ chromedriver --url-base=/wd/hub --whitelisted-ips="172.17.0.2"
$ docker run --rm -it -e BEHAVE_RUN_LOCAL=true -v $(pwd):/behave obscuritylabs/behave-selenium
```

If you have issues with this, have other containers running, or would like to ensure that the IP address is predictable for any other reason, you can run the following docker compose file instead, and whitelist `172.23.0.2` (or whatever you want to change it to, 23 is just my favorite number).

```docker
version: '3'
services:
  behave:
    image: obscuritylabs/behave-selenium
    environment: 
      - BEHAVE_RUN_LOCAL=true
    volumes: 
      - .:/behave
    networks: 
      static-network:
        ipv4_address: 172.23.0.2
networks: 
  static-network:
    ipam:
      config:
        - subnet: 172.23.0.0/16
```