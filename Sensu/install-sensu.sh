#!/bin/bash
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

apt-get update && apt-get install -y build-essential git-core supervisor sensu uchiwa
echo "sensu hold" | dpkg --set-selections

echo "EMBEDDED_RUBY=true" > /etc/default/sensu & ln -s /opt/sensu/embedded/bin/ruby /usr/bin/ruby
echo "LOG_LEVEL=info" > /etc/default/sensu
/opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri
/opt/sensu/embedded/bin/gem install mail --no-rdoc --no-ri --version 2.5.4
/opt/sensu/embedded/bin/gem install influxdb --no-rdoc --no-ri

rm -rf /etc/sensu/plugins
git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins

cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/
find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

curl https://www.openssl.org/source/openssl-1.0.1h.tar.gz | tar xz && \
            cd openssl-1.0.1h && sudo ./config && sudo make && sudo make install

mkdir -p /etc/sensu/ssl
cp /tmp/ssl_certs/client/cert.pem /tmp/ssl_certs/client/key.pem /etc/sensu/ssl
