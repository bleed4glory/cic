#!/usr/bin/env bash

#update apt-get
apt-get update

#install some pre-reqs
apt-get install -y git nodejs curl build-essential libssl-dev libcurl4-openssl-dev libsqlite3-dev zlib1g-dev libpcre3-dev libgeoip-dev checkinstall

echo "install rbenv & ruby"
sleep 2
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
#exec $SHELL -l
source ~./bashrc
mkdir -p ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
~/.rbenv/bin/rbenv install 2.0.0-p195
~/.rbenv/bin/rbenv global 2.0.0-p195
~/.rbenv/bin/rbenv rehash
ruby -v

#install ruby from source
#wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.tar.gz

#tar -xvf ruby-2.0.0-p247.tar.gz
#cd ruby-2.0.0-p247
#./configure  
#make
#make install

echo "install rails and bundler"
sleep 2
gem install rails --no-ri --no-rdoc
gem install bundler --no-ri --no-rdoc

#install unicorn
gem install unicorn --no-ri --no-rdoc

#sample app
cd /usr/local
git clone git://github.com/bleed4glory/helloworld.git helloworld

#configure unicorn
mkdir helloworld/tmp
mkdir helloworld/tmp/pids
cd helloworld/config
wget https://raw.github.com/bleed4glory/cic/master/unicorn.rb

#mkdir /etc/unicorn
#cd /etc/unicorn
#wget https://raw.github.com/bleed4glory/cic/master/helloworld.conf

cd /etc/init.d
wget https://raw.github.com/bleed4glory/cic/master/unicorn_init

#set permissions on the script
chmod 755 /etc/init.d/unicorn_init

#start unicorn
/etc/init.d/unicorn_init start