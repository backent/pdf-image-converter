FROM alpine:3.12.12

# if ever you need to change phantom js version number in future ENV comes handy as it can be used as a dynamic variable
ENV PHANTOMJS_VERSION=2.1.1

# start

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories

RUN apk upgrade musl
# Add Build Dependencies
RUN apk update && apk add --no-cache --virtual .build-deps  \
    nodejs \
    npm \
    yarn \
    supervisor \
    git \
    openssh \
    ttf-ubuntu-font-family \
    fontconfig \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    jpegoptim \
    pngquant \
    optipng \
    supervisor \
    nano \
    icu-dev \
    freetype-dev \
    nginx \
    libzip-dev \
    git \
    curl \
    ghostscript \
    graphicsmagick 

# magic command
RUN cd /tmp && curl -Ls https://github.com/dustinblackman/phantomized/releases/download/${PHANTOMJS_VERSION}/dockerized-phantomjs.tar.gz | tar xz && \
    cp -R lib lib64 / && \
    cp -R usr/lib/x86_64-linux-gnu /usr/lib && \
    cp -R usr/share /usr/share && \
    cp -R etc/fonts /etc && \
    curl -k -Ls https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 | tar -jxf - && \
    cp phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    rm -fR phantomjs-${PHANTOMJS_VERSION}-linux-x86_64

# Remove Build Dependencies
# RUN apk del curl
# RUN apk del -f .build-deps


# end

WORKDIR /app
COPY package.json ./
RUN npm install
COPY ./ .
COPY ./.docker/supervisor/supervisor.conf /etc/supervisor/ 

RUN find ./.docker/run/run.sh -exec sed -i -e 's/\r$//' {} \; && \
    find ./.docker/run/run.sh -exec chmod 775 {} \;

EXPOSE 3000
CMD ["/app/.docker/run/run.sh"]

