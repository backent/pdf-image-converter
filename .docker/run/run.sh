#!/bin/sh
npm run build
# rm -rf /app/*
# mv /temp/app/dist/* /app

/usr/bin/supervisord -n -c /etc/supervisor/supervisor.conf


