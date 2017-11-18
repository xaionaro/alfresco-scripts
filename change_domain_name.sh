#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DOMAIN_OLD="$1"; shift
DOMAIN_NEW="$1"; shift

if [ "$DOMAIN_OLD" = '' -o "$DOMAIN_NEW" = '' ]; then
	echo "Usage: $0 old.domain new.domain" >&2
	exit 1
fi

if ! host "$DOMAIN_NEW"; then
	echo "Invalid domain name: \"$DOMAIN_NEW\"" >&2
	exit 2
fi

if ! grep "Host $DOMAIN_OLD;" /etc/nginx/sites-enabled/* > /dev/null; then
	echo "Old domain name is not \"$DOMAIN_OLD\"" >&2
	exit 3
fi

sed -e "s/$DOMAIN_OLD/$DOMAIN_NEW/g" -i \
	/etc/hosts \
	/etc/nginx/sites-enabled/* \
	/opt/alfresco-community/tomcat/conf/server.xml \
	/opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties \
	/opt/alfresco-community/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml \

nginx -s reload
service alfresco restart

