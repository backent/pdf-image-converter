FROM nginx:stable-alpine
RUN apk add --update nodejs npm yarn supervisor git openssh
RUN apk --update add ttf-ubuntu-font-family fontconfig && rm -rf /var/cache/apk/*

# if ever you need to change phantom js version number in future ENV comes handy as it can be used as a dynamic variable
ENV PHANTOMJS_VERSION=2.1.1

# magic command
RUN apk add --no-cache curl ghostscript graphicsmagick 
RUN cd /tmp && curl -Ls https://github.com/dustinblackman/phantomized/releases/download/${PHANTOMJS_VERSION}/dockerized-phantomjs.tar.gz | tar xz && \
    cp -R lib lib64 / && \
    cp -R usr/lib/x86_64-linux-gnu /usr/lib && \
    cp -R usr/share /usr/share && \
    cp -R etc/fonts /etc && \
    curl -k -Ls https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 | tar -jxf - && \
    cp phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    rm -fR phantomjs-${PHANTOMJS_VERSION}-linux-x86_64 && \
    apk del curl

WORKDIR /app
COPY package.json ./
RUN npm install
COPY ./ .
COPY ./.docker/supervisor/supervisor.conf /etc/supervisor/ 

RUN find ./.docker/run/run.sh -exec sed -i -e 's/\r$//' {} \; && \
    find ./.docker/run/run.sh -exec chmod 775 {} \;

EXPOSE 3000
CMD ["/app/.docker/run/run.sh"]

