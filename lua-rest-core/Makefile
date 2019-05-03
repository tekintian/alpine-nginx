OPENRESTY_PREFIX=/usr

#LUA_VERSION := 5.1 
PREFIX ?=          /etc/nginx/lua
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/$(LUA_VERSION)
INSTALL ?= install

.PHONY: all test install

all: ;

install: all
	$(INSTALL) -d $(DESTDIR)$(LUA_LIB_DIR)/resty/core/
	$(INSTALL) -d $(DESTDIR)$(LUA_LIB_DIR)/ngx/
	$(INSTALL) -d $(DESTDIR)$(LUA_LIB_DIR)/ngx/ssl
	$(INSTALL) lib/resty/*.lua $(DESTDIR)$(LUA_LIB_DIR)/resty/
	$(INSTALL) lib/resty/core/*.lua $(DESTDIR)$(LUA_LIB_DIR)/resty/core/
	$(INSTALL) lib/ngx/*.lua $(DESTDIR)$(LUA_LIB_DIR)/ngx/
	$(INSTALL) lib/ngx/ssl/*.lua $(DESTDIR)$(LUA_LIB_DIR)/ngx/ssl/

test: all
	PATH=$(OPENRESTY_PREFIX)/sbin:$$PATH prove -I../test-nginx/lib -r t

