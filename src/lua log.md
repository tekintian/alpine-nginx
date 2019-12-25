



~~~conf
server {
    listen 80;
    server_name _;
    root /var/www/public;
    index index.php index.html index.htm ;
    #error page
    #error_page 404             /404.html;
    #error_page 500 502 503 504 /50x.html;
    location / {
      # Naxsi config
    # 启用Naxsi模块 并拦截指定的非法请求。如果要关闭Naxsi模块，可使用SecRulesDisabled选项。
      SecRulesEnabled;
      # 拒绝访问时展示的页面
      DeniedUrl "/RequestDenied";
      # 启用学习模式，即拦截请求后不拒绝访问，只将触发规则的请求写入日志。建议开发模式的时候启用学习模式
      # LearningMode;
      LibInjectionSql; #enable libinjection support for SQLI
      LibInjectionXss; #enable libinjection support for XSS
      # 检查规则 确定 naxsi 何时采取行动
      CheckRule "$SQL >= 8" BLOCK; #the action to take when the $SQL score is superior or equal to 8
      CheckRule "$RFI >= 8" BLOCK;
      CheckRule "$TRAVERSAL >= 5" BLOCK;
      CheckRule "$UPLOAD >= 5" BLOCK;
      CheckRule "$XSS >= 8" BLOCK;
      # Naxsi config end
      # lua log
      log_by_lua '
              local logger = require "resty.logger.socket"
              if not logger.initted() then
                  local ok, err = logger.init{
                      host = '118.24.132.253',
                      port = 514,
                      flush_limit = 1234,
                      drop_limit = 5678,
                  }
                  if not ok then
                      ngx.log(ngx.ERR, "failed to initialize the logger: ",
                              err)
                      return
                  end
              end

              -- construct the custom access log message in
              -- the Lua variable "msg"

              local bytes, err = logger.log(msg)
              if err then
                  ngx.log(ngx.ERR, "failed to log message: ", err)
                  return
              end
          ';
    # lua log end
  }
    # 
# for laravel rewrite
  # location / {
  #   try_files $uri /index.php?$args;
  # }

#rewrite for thinkphp
  # if (!-e $request_filename) {
  #   rewrite "^/(.*)"  /index.php?s=/$1 last;
  #   break;
  # }

  # 与php容器协同工作 start
  # fastcgi_pass [连接容器的名字或则别名]:9000， 如不需要PHP支持，可删除本段
   location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
       #安装相应的PHP容器后再打开这里即可支持PHP, 
        #fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param QUERY_STRING    $query_string;
        fastcgi_param REQUEST_METHOD  $request_method;
        fastcgi_param CONTENT_TYPE    $content_type;
        fastcgi_param CONTENT_LENGTH  $content_length;
    }
    # 与php容器协同工作end
    #just for test lua
    # more info for lua nginx https://github.com/openresty/lua-nginx-module
    # https://github.com/openresty/encrypted-session-nginx-module
    location /hello {
      default_type 'text/plain';
      content_by_lua 'ngx.say("hello, lua")';
    }
    location /lua_content {
         # MIME type determined by default_type:
         default_type 'text/plain';

         content_by_lua_block {
             ngx.say('Hello,world!')
         }
     }
     location /nginx_var {
         # MIME type determined by default_type:
         default_type 'text/plain';
         # try access /nginx_var?a=hello,world
         content_by_lua_block {
             ngx.say(ngx.var.arg_a)
         }
     }
     location /redis_demo {
            content_by_lua_block {
                local redis = require "resty.redis"
                local red = redis:new()

                red:set_timeout(1000) -- 1 sec

                -- or connect to a unix domain socket file listened
                -- by a redis server:
                --     local ok, err = red:connect("unix:/path/to/redis.sock")

                local ok, err = red:connect("127.0.0.1", 6379)
                if not ok then
                    ngx.say("failed to connect: ", err)
                    return
                end

                ok, err = red:set("dog", "an animal")
                if not ok then
                    ngx.say("failed to set dog: ", err)
                    return
                end

                ngx.say("set result: ", ok)

                local res, err = red:get("dog")
                if not res then
                    ngx.say("failed to get dog: ", err)
                    return
                end

                if res == ngx.null then
                    ngx.say("dog not found.")
                    return
                end

                ngx.say("dog: ", res)

                red:init_pipeline()
                red:set("cat", "Marry")
                red:set("horse", "Bob")
                red:get("cat")
                red:get("horse")
                local results, err = red:commit_pipeline()
                if not results then
                    ngx.say("failed to commit the pipelined requests: ", err)
                    return
                end

                for i, res in ipairs(results) do
                    if type(res) == "table" then
                        if res[1] == false then
                            ngx.say("failed to run command ", i, ": ", res[2])
                        else
                            -- process the table value
                        end
                    else
                        -- process the scalar value
                    end
                end

                -- put it into the connection pool of size 100,
                -- with 10 seconds max idle time
                local ok, err = red:set_keepalive(10000, 100)
                if not ok then
                    ngx.say("failed to set keepalive: ", err)
                    return
                end

                -- or just close the connection right away:
                -- local ok, err = red:close()
                -- if not ok then
                --     ngx.say("failed to close: ", err)
                --     return
                -- end
            }
        }
      location /cookie_test {
            content_by_lua '
                local ck = require "resty.cookie"
                local cookie, err = ck:new()
                if not cookie then
                    ngx.log(ngx.ERR, err)
                    return
                end

                -- get single cookie
                local field, err = cookie:get("lang")
                if not field then
                    ngx.log(ngx.ERR, err)
                    return
                end
                ngx.say("lang", " => ", field)

                -- get all cookies
                local fields, err = cookie:get_all()
                if not fields then
                    ngx.log(ngx.ERR, err)
                    return
                end

                for k, v in pairs(fields) do
                    ngx.say(k, " => ", v)
                end

                -- set one cookie
                local ok, err = cookie:set({
                    key = "Name", value = "Bob", path = "/",
                    domain = "example.com", secure = true, httponly = true,
                    expires = "Wed, 09 Jun 2021 10:18:14 GMT", max_age = 50,
                    samesite = "Strict", extension = "a4334aebaec"
                })
                if not ok then
                    ngx.log(ngx.ERR, err)
                    return
                end

                -- set another cookie, both cookies will appear in HTTP response
                local ok, err = cookie:set({
                    key = "Age", value = "20",
                })
                if not ok then
                    ngx.log(ngx.ERR, err)
                    return
                end
            ';
        }
     #just for test lua end
    # 配置拦截后拒绝访问时展示的页面，这里直接返回403。
    location /RequestDenied {
      return 403;
    }
    #静态资源缓存配置
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ { expires 30d;  access_log off; }
    location ~ .*\.(js|css)?$ { expires 7d; access_log off; }
    location ~ /\.ht { deny all; }
  }


~~~