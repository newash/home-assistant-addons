#!/usr/bin/with-contenv bashio

CONFDIR=/data/uacme
DOMAIN=$(bashio::config 'domain')

mkdir -p $CONFDIR

if [ ! -f "${CONFDIR}/private/key.pem" ]; then
  echo "--- Creating a new account"
  uacme -v -c $CONFDIR -y new
fi

echo "--- Issuing a new certificate for $DOMAIN"
ualpn -v -d -u nobody:nogroup -b 0.0.0.0@8000 -c 127.0.0.1 -S 666
uacme -v -c $CONFDIR -h /usr/share/uacme/ualpn.sh issue "$DOMAIN"

cp -f "${CONFDIR}/${DOMAIN}/cert.pem" "/ssl/$(bashio::config 'certfile')"
cp -f "${CONFDIR}/private/${DOMAIN}/key.pem" "/ssl/$(bashio::config 'keyfile')"

ualpn -v -t

echo "--- Certificate set"
