#!/bin/bash
#
# start.sh
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA  02111-1307  USA
#
# Author:   Pietro Delsante <p.delsante AT gmail.com>
#

# Send all output (stdout + stderr) to a log file

exec > >(tee /var/log/rumal_backend-startup.log)
exec 2>&1

 
#add docker to root group + start docker
#usermod -aG docker root
docker daemon > /var/log/docker-daemon.log 2>&1 &

# Mongodb listening on interfaces
sed -i 's/^  bindIp: 127.0.0.1/  bindIp: 0.0.0.0/' /etc/mongod.conf


# pull thug
echo "Pulling Thug ... this may take a while..."
docker pull pdelsante/thug-dockerfile

#Mongo db in background
/usr/bin/sudo /usr/bin/mongod --smallfiles --fork --logpath /var/log/mongod.log

# Start RabbitMQ server
/usr/sbin/rabbitmq-server > /var/log/rabbit-server.log 2>&1 &
echo $! > /var/run/rabbit.pid

echo "Starting Rumal's backend worker daemon..." 
/usr/bin/python /opt/rumal_back/manage.py run_thug >/var/log/rumal_back-run_thug.log 2>&1 &
echo $! > /var/run/rumal_back-run_thug.pid

echo "Starting Rumal's backend HTTP Server..."
/usr/bin/python /opt/rumal_back/manage.py runserver 0.0.0.0:8000 >/var/log/rumal_back-web.log 2>&1 &
echo $! > /var/run/rumal_back-http.pid

echo "Starting Rabbit backend server..."
rabbitmqctl wait /var/run/rabbit.pid
rabbitmqctl add_user admin admin # add admin user
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" # give all permissions to admin user
/usr/bin/sudo /usr/bin/python /opt/rumal_back/manage.py consumer >/var/log/rumal_back-consumer.log 2>&1 &
echo $! > /var/run/rumal_back-consumer.pid

# Give a hint about how to use
echo "Running on: http://"$(hostname -i)":8000/"
echo "Username: admin"
echo "Api-Key: "$(sqlite3 db.sqlite3 'SELECT `key` FROM tastypie_apikey WHERE user_id = (SELECT id FROM auth_user WHERE username = '"'"'admin'"'"');')


# Check if processes are still alive
while true; do 
    kill -0 $(cat /var/run/rumal_back-http.pid) > /dev/null
    if [ $? -eq 1 ]; then
        /usr/bin/python /opt/rumal_back/manage.py runserver 0.0.0.0:8000 >/var/log/rumal_back-web.log 2>&1 &
        echo $! > /var/run/rumal_back-http.pid
    fi
    kill -0 $(cat /var/run/rumal_back-run_thug.pid) > /dev/null
    if [ $? -eq 1 ]; then
        /usr/bin/python /opt/rumal_back/manage.py run_thug >/var/log/rumal_back-run_thug.log 2>&1 &
		echo $! > /var/run/rumal_back-run_thug.pid
    fi
    kill -0 $(cat /var/run/rumal_back-consumer.pid) > /dev/null
    if [ $? -eq 1 ]; then
        /usr/bin/python /opt/rumal_back/manage.py consumer >/var/log/rumal_back-consumer.log 2>&1 &
		echo $! > /var/run/rumal_back-consumer.pid
    fi
    sleep 60
done
