FROM python:3.8-slim-buster

LABEL maintainer="Jaime Renee Wissner <j.wissner@obscuritylabs.com>"

ENV CHROME_DRIVER_VERSION 88.0.4324.27
ENV CHROME_VERSION 88.0.4324.96-1
ENV BEHAVE_VERSION 1.2.6
ENV ELEMENTIUM_VERSION 2.0.2
ENV SELENIUM_VERSION 3.141.0

ENV CHROME_DRIVER_TARBALL http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip

RUN echo "===== Update and install basics"                      && \
      apt-get update && apt-get install -y --no-install-recommends \
        gnupg                                                      \
        dirmngr                                                    \
        wget                                                       \
        ca-certificates                                            \
      && rm -rf /var/lib/apt/lists/*

RUN echo "===== Add Google Repo" && \
      wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
      echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"       \
        | tee /etc/apt/sources.list.d/google.list

RUN echo "===== Install prerequisite stuff..." && \
      apt-get update                           && \
      apt-get install -y --no-install-recommends  \
        xvfb                                      \
        libfontconfig                             \
        libfreetype6                              \
        xfonts-scalable                           \
        fonts-liberation                          \
        fonts-noto-cjk                            \
        google-chrome-stable=${CHROME_VERSION}

RUN echo "===== Install ChromeDriver"                                        && \
      wget -qO- $CHROME_DRIVER_TARBALL | zcat > /usr/local/bin/chromedriver  && \
      chown root:root /usr/local/bin/chromedriver                            && \
      chmod 0755 /usr/local/bin/chromedriver

RUN echo "===== Pip Install"           && \
      pip3 install --no-cache-dir         \
        requests                          \
        behave==${BEHAVE_VERSION}         \
        elementium==${ELEMENTIUM_VERSION} \
        selenium==${SELENIUM_VERSION}     \
        xvfbwrapper

RUN echo "===== Clean Up" && \
      rm -rf /var/lib/apt/lists/*

COPY wrapper.sh /tmp
RUN  chmod +x /tmp/wrapper.sh

ENV BEHAVE_RUN_LOCAL false

WORKDIR    /behave
ENV        REQUIREMENTS_PATH  /behave/features/steps/requirements.txt
ENTRYPOINT ["/tmp/wrapper.sh"]