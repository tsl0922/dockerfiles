FROM ubuntu:16.04
LABEL maintainer "Shuanglei Tao - tsl0922@gmail.com"

ENV FDFS_LIB_COMMIT c78f6b17eeb4ba72d84436c8ae9a23ec82beb6a9
ENV FDFS_COMMIT 5d0d1ef5319c39165b7703b2af89442c3a801eb5
ENV FDFS_MOD_COMMIT be5fb92634683de745191f5619809f4d3409df14

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    g++ \
    automake \
    autoconf \
    libtool \
    libpcre3-dev \
    libssl-dev \
    make \
    vim

RUN git clone https://github.com/happyfish100/libfastcommon.git /tmp/libfastcommon \
  && cd /tmp/libfastcommon && git checkout $FDFS_LIB_COMMIT \
  && ./make.sh && ./make.sh install \
  && git clone https://github.com/happyfish100/fastdfs.git /tmp/fastdfs \
  && cd /tmp/fastdfs && git checkout $FDFS_COMMIT \
  && ./make.sh && ./make.sh install \
  && cp conf/http.conf /etc/fdfs && cp conf/mime.types /etc/fdfs

RUN git clone https://github.com/happyfish100/fastdfs-nginx-module.git /tmp/fastdfs-nginx-module \
  && cd /tmp/fastdfs-nginx-module && git checkout $FDFS_MOD_COMMIT && cp src/mod_fastdfs.conf /etc/fdfs \
  && curl -sLo- https://nginx.org/download/nginx-1.11.10.tar.gz | tar xz -C /tmp \
  && cd /tmp/nginx-1.11.10 \
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
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-ipv6 \
    --add-module=../fastdfs-nginx-module/src \
  && make && make install \
  && adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx \
  && mkdir -p /var/cache/nginx && chown -R nginx:nginx /var/cache/nginx \
  && mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

COPY ./nginx.conf /etc/nginx/

RUN apt-get remove -y --purge \
    git \
    g++ \
    automake \
    autoconf \
    libtool \
    make \
  && apt-get purge -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]