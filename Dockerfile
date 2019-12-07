# Node includes all necessary components for puppeteer.
FROM node:13.1.0-slim

# Install xvfb and any dependencies of it as well as 
# the puppeteer ones. By default no display is present 
# in a docker container, so we must provide a fake one 
# in order to make chrome run properly.
RUN apt-get update && \
    apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget x11vnc x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic x11-apps xvfb

# Install latest chrome dev package, which installs the necessary libs to
# make the bundled version of Chromium that Puppeteer installs work.
RUN apt-get update \
    && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Disable puppeteer chromium installation. 
# We will use the actual chrome installation.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install Puppeteer under /node_modules so it's available system-wide.
ADD package.json package-lock.json /
RUN npm install
ENV PATH="${PATH}:/node_modules/.bin"

# ------------------------------------------------------------
# The following commands can be changed as desired. Here mocha 
# is used to execute js-files. Just make sure to wrap the 
# startup command with "xvfb-run" since this enables the fake 
# display for chrome.
# ------------------------------------------------------------

# Install any dependencies that you have. 
# I use mocha for executing js-files.
RUN npm install mocha

# Needed arguments in the script are:
# --no-sandbox
# --disable-setuid-sandbox
#
# Any form of startup command can be used 
# here. The most important part is starting 
# the whole application via xvfb as shown 
# below. xvfb-run wraps the command (mocha) 
# and executes it in a headful environment.
# Replace "mocha --recursive /integration-tests" 
# with the startup command of your application 
# if you replace mocha.
CMD xvfb-run --server-args="-screen 0 1024x768x24" mocha --recursive /integration-tests