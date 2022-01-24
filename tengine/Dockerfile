FROM ubuntu:16.04
LABEL maintainer "Shuanglei Tao - tsl0922@gmail.com"

RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		ca-certificates \
		curl \
		build-essential \
		libpcre3-dev \
		libssl-dev \
		zlib1g-dev

WORKDIR /usr/src/

RUN curl -sLo- https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20211210.tar.gz | tar zx \
	&& make PREFIX=/usr -C /usr/src/luajit2-2.1-20211210 amalg \
	&& make PREFIX=/usr -C /usr/src/luajit2-2.1-20211210 install

RUN curl -sLo- https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz | tar zx \
	&& curl -sLo- https://github.com/vozlt/nginx-module-vts/archive/v0.1.18.tar.gz | tar zx \
	&& curl -sLo- http://tengine.taobao.org/download/tengine-2.3.3.tar.gz | tar zx \
	&& curl -sLo- https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar jx

RUN cd tengine-2.3.3 \
	&& export LUAJIT_LIB=/usr/lib \
	&& export LUAJIT_INC=/usr/include/luajit-2.1 \
	&& ./configure \
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--with-http_realip_module \
		--with-http_gzip_static_module \
		--with-http_gunzip_module \
		--with-http_ssl_module \
		--with-http_sub_module \
		--with-http_v2_module \
		--with-http_lua_module \
		--with-file-aio \
		--with-ipv6 \
		--add-module=../headers-more-nginx-module-0.33 \
		--add-module=../nginx-module-vts-0.1.18 \
		--with-jemalloc=../jemalloc-5.2.1 \
	&& make && make install \
	&& mkdir -p /var/cache/nginx \
	&& rm -rf /usr/src /tmp/* \
	&& apt-get purge -y --auto-remove \
	&& apt-get clean all \
	&& rm -rf /var/lib/apt/lists/*
WORKDIR /

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN adduser --system \
	--no-create-home \
	--group \
	--disabled-login \
	--disabled-password \
	nginx

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
