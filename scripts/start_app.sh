#!/bin/bash
nohup java -jar /opt/storeyes/app.jar \
  --spring.profiles.active=prod \
  > /var/log/storeyes.log 2>&1 &
