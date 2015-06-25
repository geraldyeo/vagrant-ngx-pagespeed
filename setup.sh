##
# Custom Nginx build with pagespeed in Centos-7
#
# Instructions from https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source
##

# Versions
EPEL_VERSION=7
NPS_VERSION=1.9.32.4
NGINX_VERSION=1.8.0 # check http://nginx.org/en/download.html for the latest version

# Install EPEL
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-${EPEL_VERSION}.noarch.rpm

# Install build tools
sudo yum install -y gcc-c++ pcre-devel zlib-devel make wget openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools-devel git unzip memcached

# Create nginx user without shell
sudo useradd -r -M nginx

# Download ngx_pagespeed
cd
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
unzip release-${NPS_VERSION}-beta.zip
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
tar -xzvf ${NPS_VERSION}.tar.gz  # extracts to psol/

# Download, configure and build nginx with support for pagespeed
cd
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}/

./configure \
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--user=nginx \
	--group=nginx \
	--with-file-aio \
	--with-ipv6 \
	--with-http_ssl_module \
	--with-http_spdy_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_xslt_module \
	--with-http_image_filter_module \
	--with-http_geoip_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_degradation_module \
	--with-http_stub_status_module \
	--with-http_perl_module \
	--with-ld-opt="-Wl,-E" \
	--with-mail \
	--with-mail_ssl_module \
	--with-pcre \
	--with-google_perftools_module \
	--with-debug \
	--add-module=$HOME/ngx_pagespeed-release-${NPS_VERSION}-beta

make && sudo make install

# Copy the nginx conf
sudo cp /vagrant/nginx/nginx.conf /etc/nginx/nginx.conf

# Copy memcached conf
sudo cp /vagrant/nginx/memcached /etc/sysconfig/

# Copy Nginx init script
sudo cp /vagrant/nginx/nginx.service /usr/lib/systemd/system/
sudo chmod 644 /usr/lib/systemd/system/nginx.service

# Create nginx virtual host
sudo mkdir /etc/nginx/sites-available /etc/nginx/sites-enabled
sudo cp /vagrant/nginx/redmart.com /etc/nginx/sites-available/
cd /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/redmart.com

# Create cache dir
sudo mkdir /var/ngx_pagespeed_cache
sudo chown nginx:nginx /var/ngx_pagespeed_cache

# start memcached
sudo systemctl enable memcached
sudo systemctl start memcached

# start nginx on boot
sudo systemctl enable nginx
sudo systemctl start nginx