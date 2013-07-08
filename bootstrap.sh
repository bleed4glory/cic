#!/usr/bin/env bash

#update apt-get
apt-get update

#install some pre-reqs
apt-get install -y git curl build-essential libssl-dev libcurl4-openssl-dev libsqlite3-dev

#install rbenv, ruby, rails and bundler 
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL -l
mkdir -p ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
rbenv install 2.0.0-p195
rbenv global 2.0.0-p195
gem install bundler
gem install rails --no-rdoc --no-ri

#install unicorn
gem install unicorn

#sample app
cd /usr/local
rails new helloworld

#configure unicorn
cd helloworld
mkdir config
wget https://raw.github.com/bleed4glory/cic/master/unicorn.rb config

mkdir /etc/unicorn
cd /etc/unicorn
wget https://raw.github.com/bleed4glory/cic/master/helloworld.conf


wget https://raw.github.com/bleed4glory/cic/master/unicorn_init /etc/init.d/unicorn_init.sh

#set permissions on the script
chmod 755 /etc/init.d/unicorn_init

#start unicorn
/etc/init.d/unicorn_init start