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
mkdir /etc/unicorn

cat > /etc/unicorn/helloworld.conf << EOF
RAILS_ROOT=/usr/local/helloworld
RAILS_ENV=production
EOF

cat > /usr/local/helloworld/config/unicorn.rb << EOF
# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

app_path = "/usr/local/helloworld"

listen 2007 # by default Unicorn listens on port 8080
worker_processes 2 # this should be >= nr_cpus
pid "#{app_path}/tmp/pids/unicorn.pid"
stderr_path "#{app_path}/log/unicorn.log"
stdout_path "#{app_path}/log/unicorn.log"
EOF

cat > /etc/init.d/unicorn_init.sh << EOF
#!/bin/sh
#
# init.d script for single or multiple unicorn installations. Expects at least one .conf 
# file in /etc/unicorn
#
# Modified by jay@gooby.org http://github.com/jaygooby
# based on http://gist.github.com/308216 by http://github.com/mguterl
#
## A sample /etc/unicorn/my_app.conf
## 
## RAILS_ENV=production
## RAILS_ROOT=/var/apps/www/my_app/current
#
# This configures a unicorn master for your app at /var/apps/www/my_app/current running in
# production mode. It will read config/unicorn.rb for further set up. 
#
# You should ensure different ports or sockets are set in each config/unicorn.rb if
# you are running more than one master concurrently.
#
# If you call this script without any config parameters, it will attempt to run the
# init command for all your unicorn configurations listed in /etc/unicorn/*.conf
#
# /etc/init.d/unicorn start # starts all unicorns
#
# If you specify a particular config, it will only operate on that one
#
# /etc/init.d/unicorn start /etc/unicorn/my_app.conf
 
set -e
 
cmd () {
 
  case $1 in
    start)
      echo $DAEMON_OPTS
      start-stop-daemon --start --quiet --pidfile $PID \
                --exec $DAEMON -- $DAEMON_OPTS || true
      echo "Starting with config: $RAILS_ROOT/config/unicorn.rb"
      ;;  
    stop)
      start-stop-daemon --stop --quiet --pidfile $PID || true
      echo "Stopping with config: $RAILS_ROOT/config/unicorn.rb"
      ;;  
    restart|reload)
      start-stop-daemon --stop --quiet --pidfile $PID || true
      echo "Stopping with config: $RAILS_ROOT/config/unicorn.rb"
      sleep 1
      start-stop-daemon --start --quiet --pidfile $PID \
                --exec $DAEMON -- $DAEMON_OPTS || true
      echo "Starting with config: $RAILS_ROOT/config/unicorn.rb"
      ;;  
    *)  
      echo >&2 "Usage: $0 <start|stop|restart>"
      exit 1
      ;;  
    esac
}
 
setup () {
 
  export PID=$RAILS_ROOT/tmp/pids/unicorn.pid
  export OLD_PID="$PID.oldbin"
 
  DAEMON="`which unicorn_rails`"
  DAEMON_OPTS="-c $RAILS_ROOT/config/unicorn.rb -E $RAILS_ENV -D"
}
 
start_stop () {
  
  # either run the start/stop/reload/etc command for every config under /etc/unicorn
  # or just do it for a specific one
 
  # $1 contains the start/stop/etc command
  # $2 if it exists, should be the specific config we want to act on
  if [ $2 ]; then
    . $2
    setup
    cmd $1
  else
    for CONFIG in /etc/unicorn/*.conf; do
      # import the variables
      . $CONFIG
      setup
 
      # run the start/stop/etc command
      cmd $1
    done
   fi
}
 
ARGS="$1 $2"
start_stop $ARGS
EOF

#set permissions on the script
chmod 755 /etc/init.d/unicorn_init.sh

#start unicorn
/etc/init.d/unicorn_init start