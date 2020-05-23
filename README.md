# alpine nginx docker container

基于alpine的nginx 容器

默认nginx用户为 www-data

默认工作目录目录： /var/www/public


apk add --no-cache g++ autoconf automake pkgconfig leptonica-dev libtool libpng libjpeg tiff zlib leptonica
./autogen.sh
./configure --prefix=$HOME/local/
make
make install

libicu-devel  libpango1.0-dev  libcairo-dev


#fastcgi_pass php:9000;


To reload the NGINX configuration, run this command:
#重新加载容器中的nginx配置文件 相当于 service nginx reload
docker kill -s HUP nginx

#重启nginx容器 【nginx为你的nginx容器的名称】
docker restart nginx


使用nginx自带参数 -s 停止nginx
/usr/local/nginx/sbin/nginx -s stop

重新加载配置
/usr/local/nginx/sbin/nginx -s reload


To reload the NGINX configuration, run this command:

docker kill -s HUP nginx

To restart NGINX, run this command to restart the container:

docker restart nginx



kill -HUP 【旧的主进程号】：nginx 将在不重载配置文件的情况下启动它的工作进程

kill -QUIT 【新的主进程号】：从容关闭其工作进程(worker process)

kill -TERM 【新的主进程号】：强制退出

kill 【新的主进程号或旧的主进程号】：如果因为某些原因新的工作进程不能退出，则向其发送 kill 信号



## nginx配置示例

```conf
server {
    listen 80;
    server_name _;
    root /home/wwwroot/myweb/public;
    index index.php index.html index.htm;
    #error_page 404 /404.html;
    #error_page 502 /502.html;

   # for laravel rewrite
   # location / {
    #    try_files $uri /index.php?$args;
   # }
   
   #rewrite for thinkphp
   if (!-e $request_filename) {
     rewrite "^/(.*)"  /index.php?s=/$1 last;
     break;
   }
  # 与php容器协同工作
   location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    #静态资源缓存配置
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
      expires 30d;
      access_log off;
    }
    location ~ .*\.(js|css)?$ {
      expires 7d;
      access_log off;
    }
    location ~ /\.ht {
      deny all;
    }
  }
```



## nginx + php-fpm+mariadb/mysql 容器协同工作配置示例

```yml

# nginx容器 yml配置

nginx:
  image: tekintian/nginx:1.15.7-alpine
  privileged: false
  restart: always
  external_links:
  - php70fpm_1:php
  - mariadb:db
  ports:
  - '80:80'


# PHP容器yml配置

php70fpm:
  image: tekintian/php:7.0-fpm-alpine
  privileged: false
  restart: always
  ports:
  - '9070:9000'
  #与nginx共享数据
  volumes_from:
  - nginx
  external_links:
  - mariadb:db


# mariadb yml配置

mariadb104:
  image: library/mariadb:10.4
  privileged: false
  restart: always
  ports:
  - '3304:3306'
  volumes:
  - /home/dcdata/mariadb104/conf.d:/etc/mysql/conf.d
  - /home/dcdata/mariadb104/data:/var/lib/mysql
  environment:
  - MYSQL_ROOT_PASSWORD=888888
  - character-set-server=utf8mb4
  - collation-server=utf8mb4_unicode_ci


# 然后在nginx容器中就 可以使用  db 作为数据库的服务器地址来用了，注意端口是3306 不是你对外暴露的端口。
```

~~~shell

docker build -f naxsi.Dockerfile -t tekintian/alpine-nginx:naxsi .


# alpine 3.10
docker build -f Dockerfile -t tekintian/alpine-nginx .
docker build -f 1.18.Dockerfile -t tekintian/alpine-nginx:1.18 .
docker build -f 1.18.Dockerfile -t tekintian/alpine-nginx:1.18.0 .

docker build -f 1.18lua.Dockerfile -t tekintian/alpine-nginx:1.18lua .


docker build -f 1.17.Dockerfile -t tekintian/alpine-nginx:1.17 .
docker build -f 1.16.Dockerfile -t tekintian/alpine-nginx:1.16 .
docker build -f 1.15.Dockerfile -t tekintian/alpine-nginx:1.15 .


# alpine 3.9
docker build -f Dockerfile -t tekintian/alpine-nginx .
docker build -f stable.Dockerfile -t tekintian/alpine-nginx:stable .
docker build -f 1.15.Dockerfile -t tekintian/alpine-nginx:1.15.12 .

# alpine 3.8
docker build -f 1.16lua.Dockerfile -t tekintian/alpine-nginx:1.16lua .
docker build -f naxsi.Dockerfile -t tekintian/alpine-nginx:naxsi .

~~~

Nginx NDK + lua + naxsi 版本资源
~~~html
nginx + lua + naxsi 资源说明

modules 文件夹中的文件为 nginx的编译模块 .so文件

lua 文件夹中的为lua文件,

动态模块加载


相关资源链接:
http://nginx.org/en/docs/ngx_core_module.html#load_module

https://github.com/openresty/lua-nginx-module

https://github.com/tekintian/set-misc-nginx-module



https://github.com/nbs-system/naxsi

https://luajit.org/download.html

https://github.com/openresty/lua-nginx-module
https://github.com/openresty/lua-resty-core
https://github.com/openresty/lua-resty-lrucache
https://github.com/openresty/lua-resty-redis
https://github.com/openresty/lua-resty-mysql

https://github.com/openresty/set-misc-nginx-module
https://github.com/openresty/encrypted-session-nginx-module
https://github.com/openresty/echo-nginx-module

https://github.com/cloudflare/lua-resty-logger-socket
https://github.com/openresty/lua-resty-string
https://github.com/cloudflare/lua-resty-cookie

~~~


## Support 技术支持

​	需要其他的特定环境或则模块支持，可联系定制开发容器 ， Email: tekintian@gmail.com  QQ:932256355

如果您觉得本项目对您有用，请打赏支持开发，谢谢！

![donate](donate.png)



