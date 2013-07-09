#!/usr/bin/env bash

#commands to allow source ~/.bashrc to be used in non-interactive session
chmod a+x ~/.bashrc
PS1='$ '

#update apt-get
apt-get update

#install some pre-reqs
apt-get install -y git nodejs curl build-essential libssl-dev libcurl4-openssl-dev libsqlite3-dev zlib1g-dev libpcre3-dev libgeoip-dev checkinstall

echo "install rbenv & ruby"
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
#exec $SHELL -l
source ~/.bashrc
mkdir -p ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
rbenv install 2.0.0-p195
rbenv global 2.0.0-p195
rbenv rehash
ruby -v

echo "install rails and bundler"
gem install rails --no-ri --no-rdoc
gem install bundler --no-ri --no-rdoc

#install unicorn
gem install unicorn --no-ri --no-rdoc

#sample app
cd /usr/local
git clone git://github.com/bleed4glory/helloworld.git helloworld
cd helloworld
bundle install

#configure unicorn
mkdir tmp
mkdir tmp/pids

mkdir /etc/unicorn
cd /etc/unicorn
wget https://raw.github.com/bleed4glory/cic/master/helloworld.conf

cd /etc/init.d
wget https://raw.github.com/bleed4glory/cic/master/unicorn_init

#set permissions on the script
chmod 755 /etc/init.d/unicorn_init

#start unicorn
/etc/init.d/unicorn_init start

echo "ALL DONE! ROCK AND ROLL SON!"