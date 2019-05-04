# @Author: tekintian
# @Date:   2019-05-03 11:54:19
# @Last Modified by:   tekintian
# @Last Modified time: 2019-05-04 13:16:39
#!/bin/bash
if [ ! -d /usr/local/share/GeoIP ];then
    mkdir /usr/local/share/GeoIP
fi
# https://dev.maxmind.com/geoip/geoip2/geolite2/
wget -t 5 -O /tmp/GeoLite2-City.tar.gz https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
wget -t 5 -O /tmp/GeoLite2-Country.tar.gz https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
wget -t 5 -O /tmp/GeoIPASNum.dat.gz https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz

gzip -df /tmp/GeoLite2-City.tar.gz
gzip -df /tmp/GeoLite2-Country.tar.gz
gzip -df /tmp/GeoLite2-ASN.tar.gz

mv -f /tmp/Geo*.dat /usr/local/share/GeoIP/