#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

# Change rewrite rules
sudo rm /etc/nginx/sites-available/www.testlokaal.dev
sudo touch /etc/nginx/sites-available/www.testlokaal.dev
sudo bash -c "cat >> /etc/nginx/sites-available/www.testlokaal.dev" << 'EOL'
server {
    listen 80;
    listen 443 ssl;
    server_name www.testlokaal.dev;
    root '/home/vagrant/testlokaal';

    index index.html index.htm index.php;

    charset utf-8;

    # nginx configuration
    # nginx configuration
    error_page 500 /error_docs/internal_server_error.php;
    error_page 404 /error_docs/not_found.php;
    error_page 403 /error_docs/forbidden.php;

    location / {

        rewrite ^/(.*)/diagram/(.*)$ /index.php?fuseaction=diagram.$1/$2 break;
    
        if (!-e $request_filename) {
            rewrite ^/([A-Za-z\-]+\.[A-Za-z0-9\-]+.*)$ /index.php?fuseaction=$1;
        }
    }

    location /brochure {
        rewrite ^/brochure/(.*)\.html$ /home.brochure&url=$1 redirect;
    }

    location = /tests.html {
        rewrite ^(.*)$ /catalogus.home;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/www.testlokaal.dev-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }


    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/www.testlokaal.dev.crt;
    ssl_certificate_key /etc/nginx/ssl/www.testlokaal.dev.key;
}
EOL

# Reload nginx after config change
sudo nginx -s reload

# PDF Output
cd
mkdir -p tmp
cd tmp
wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb

# Fix NPM location
mkdir -p /vagrant/npm-global
npm config set prefix '/vagrant/npm-global'

# Install global packages
npm install -g mocha

# Install npm packages
cd /home/vagrant/testlokaal/testing
npm install
