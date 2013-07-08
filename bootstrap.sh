#!/usr/bin/env bash

#update apt-get
apt-get update

#install some pre-reqs
apt-get install -y git nodejs curl build-essential libssl-dev libcurl4-openssl-dev libsqlite3-dev zlib1g-dev libpcre3-dev libgeoip-dev checkinstall

#install rbenv, ruby, rails and bundler 
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
#exec $SHELL -l
mkdir -p ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
$HOME/.rbenv/bin/rbenv install 2.0.0-p195
$HOME/.rbenv/bin/rbenv global 2.0.0-p195
gem install bundler
gem install rails --no-rdoc --no-ri

#install unicorn
gem install unicorn

#sample app
cd /usr/local
rails new helloworld

#configure unicorn
mkdir helloworld/tmp/pids
cd helloworld/config
wget https://raw.github.com/bleed4glory/cic/master/unicorn.rb

mkdir /etc/unicorn
cd /etc/unicorn
wget https://raw.github.com/bleed4glory/cic/master/helloworld.conf

cd /etc/init.d
wget https://raw.github.com/bleed4glory/cic/master/unicorn_init

#set permissions on the script
chmod 755 /etc/init.d/unicorn_init

#start unicorn
/etc/init.d/unicorn_init start