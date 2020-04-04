FROM debian:10

COPY ./sources.list /etc/apt/

RUN apt-get update \
    && apt-get install -y wget curl gnupg2 apt-transport-https ca-certificates lsb-release sudo gettext-base --no-install-recommends --no-install-suggests \
    && curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && echo "# deb https://deb.nodesource.com/node_10.x buster main\ndeb https://mirrors.tuna.tsinghua.edu.cn/nodesource/deb_10.x buster main\n# deb-src https://deb.nodesource.com/node_10.x buster main\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/nodesource/deb_10.x buster main" | tee /etc/apt/sources.list.d/nodesource.list \
    && echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y nodejs yarn nginx nginx-module-njs nginx-module-perl nginx-module-image-filter nginx-module-geoip nginx-module-xslt --no-install-recommends --no-install-suggests \
    && ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /src/*.deb

# setup mirror for poor network environment
# https://quasar.dev/quasar-cli/installation
RUN yarn config set registry https://registry.npm.taobao.org \
    && yarn global add @quasar/cli

COPY ./nginx.conf /etc/nginx/
COPY ./default.conf /etc/nginx/conf.d/

EXPOSE 80 443


## Puppeteer dependencies, from: https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
#
## Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
## Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
## installs, work.
##RUN apt-get update && apt-get install -y wget --no-install-recommends \
##    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
##    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
##    && apt-get update \
##    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
##      --no-install-recommends \
##    && rm -rf /var/lib/apt/lists/* \
##    && rm -rf /src/*.deb
##    # apt-get purge --auto-remove -y curl 
#
WORKDIR /app
#

##    && yarn add puppeteer
#
#
ENV FRONTEND_ENV "production"
#COPY ./docker-entrypoint.sh /usr/local/bin/
COPY ./startup.sh /usr/local/bin/
VOLUME ["/usr/share/nginx/html", "/etc/nginx/conf.d", "/app"]
#ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["startup.sh"]
