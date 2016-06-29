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
exec > >(tee /var/log/rumal-startup.log)
exec 2>&1

echo "Creating backend.conf"
# Create the needed configuration files
echo "[backend]" > /opt/rumal/conf/backend.conf
echo 'host = backend' >> /opt/rumal/conf/backend.conf
echo 'rabbit_user = admin' >> /opt/rumal/conf/backend.conf
echo 'rabbit_password = admin' >> /opt/rumal/conf/backend.conf
echo 'BE = ' >> /opt/rumal/conf/backend.conf

echo "Starting mongod server..."
/usr/bin/sudo /usr/bin/mongod --smallfiles --fork --logpath /var/log/mongod.log

echo "Starting RabbitMQ server..."
/usr/sbin/rabbitmq-server > /var/log/rabbit-server.log 2>&1 &
echo $! > /var/run/rabbit.pid

echo "Starting Rumal's HTTP Server..."
/usr/bin/python /opt/rumal/manage.py runserver 0.0.0.0:8080 >/var/log/rumal-web.log 2>&1 &
echo $! > /var/run/rumal-http.pid

echo "Starting Rumal's frontend daemon..."
/usr/bin/python /opt/rumal/manage.py fdaemon >/var/log/rumal-fdaemon.log 2>&1 &
echo $! > /var/run/rumal-fdaemon.pid

echo "Starting Rumal's enrich daemon..."
/usr/bin/python /opt/rumal/manage.py enrich >/var/log/rumal-enrich.log 2>&1 &
echo $! > /var/run/rumal-enrich.pid

# Give a hint about how to use
echo "Running on: http://"$(hostname -i)":8080/"
echo "Username: admin"

# Check if processes are still alive
while true; do
    echo "Checking if rumal-http is still alive"
    kill -0 $(cat /var/run/rumal-http.pid) > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "Process rumal-http is dead, restarting it"
        /usr/bin/python /opt/rumal/manage.py runserver 0.0.0.0:8080 >/var/log/rumal-web.log 2>&1 &
        echo $! > /var/run/rumal-http.pid
    fi

    echo "Checking if rumal-fdaemon is still alive"
    kill -0 $(cat /var/run/rumal-fdaemon.pid) > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "Process rumal-fdaemon is dead, restarting it"
        /usr/bin/python /opt/rumal/manage.py fdaemon >/var/log/rumal-fdaemon.log 2>&1 &
        echo $! > /var/run/rumal-fdaemon.pid
    fi

    echo "Checking if rumal-enrich is still alive"
    kill -0 $(cat /var/run/rumal-enrich.pid) > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "Process rumal-enrich is dead, restarting it"
        /usr/bin/python /opt/rumal/manage.py enrich >/var/log/rumal-enrich.log 2>&1 &
        echo $! > /var/run/rumal-enrich.pid
    fi

    sleep 60
done
