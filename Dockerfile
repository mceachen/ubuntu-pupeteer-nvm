# Forked from https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker

FROM ubuntu:18.04

# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN  apt-get update \ 
    && apt-get install -yq libgconf-2-4 xvfb gnupg2 dumb-init build-essential wget git \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    && apt-get dist-upgrade -yq

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptr \
    && useradd --system --create-home --gid pptr --groups audio,video pptr

# Run everything after as non-privileged user.
USER pptr

ENV NVM_DIR /home/pptr/.nvm
RUN mkdir -p /home/pptr/Downloads $NVM_DIR \
    && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install 8 \
    && npm i -g npm yarn puppeteer

ENTRYPOINT ["dumb-init", "--"]
CMD ["bash", "-c", ". $NVM_DIR/nvm.sh"]

