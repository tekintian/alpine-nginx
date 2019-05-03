# @Author: tekintian
# @Date:   2019-05-03 11:54:19
# @Last Modified by:   tekintian
# @Last Modified time: 2019-05-03 11:57:46
#!/bin/bash
if [ ! -d /usr/local/share/GeoIP ];then
    mkdir /usr/local/share/GeoIP
fi

wget -t 5 -O /tmp/GeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget -t 5 -O /tmp/GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
wget -t 5 -O /tmp/GeoIPASNum.dat.gz http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz

gzip -df /tmp/GeoIP.dat.gz
gzip -df /tmp/GeoLiteCity.dat.gz
gzip -df /tmp/GeoIPASNum.dat.gz

mv -f /tmp/Geo*.dat /usr/local/share/GeoIP/