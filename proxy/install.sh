#!/bin/bash

if [ -d /etc/apache2 ] ; then

	# Set the 'ServerName' directive globally
	echo ServerName localhost >> /etc/apache2/conf-enabled/servername.conf

	# Disable the default sites
	rm -f /etc/apache2/sites-enabled/*.conf

	# Apache conf files
	mv /opt/proxy/sites-available/*.conf /etc/apache2/sites-available/
	mv /opt/proxy/sites-enabled/*.conf /etc/apache2/sites-enabled/

        # Fix permissions on Apache conf files
        find /etc/apache2 -type d -exec chmod 755 {} \;
	find /etc/apache2 -type f -exec chmod 44 {} \;

fi
