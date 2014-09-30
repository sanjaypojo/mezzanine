#!/bin/sh

export PATH=/usr/local/bin:$PATH
cd /home/sanjaypojo/mezzanine/production
forever start -c coffee --spinSleepTime 6000 --minUptime 3000 src/app.coffee
