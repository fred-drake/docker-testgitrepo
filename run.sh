#!/bin/bash

echo "Starting fcgi wrapper..."
spawn-fcgi -s /var/run/fcgiwrap.socket -M 766 /usr/sbin/fcgiwrap
id
echo "Starting nginx..."
nginx
echo "Starting SSH server..."
/etc/init.d/ssh start
echo "Ready."
while true
do
	sleep 1
done