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

# Create the needed configuration files
echo "[backend]" > /opt/rumal/conf/backend.conf
echo 'host = http://backend:8000/' >> /opt/rumal/conf/backend.conf
echo 'api_key = 4823ef79b9fa1bc0b119e20602dd34b1' >> /opt/rumal/conf/backend.conf
echo 'api_user = admin' >> /opt/rumal/conf/backend.conf

#[ -f /usr/bin/sudo ] && echo "Found" || echo "Not found"
/usr/bin/sudo /usr/bin/mongod --smallfiles --fork --logpath /var/log/mongod.log

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
    kill -0 $(cat /var/run/rumal-http.pid) > /dev/null 
    if [ $? -eq 1 ]; then
        /usr/bin/python /opt/rumal/manage.py runserver 0.0.0.0:8080 >/var/log/rumal-web.log 2>&1 &
        echo $! > /var/run/rumal-http.pid
    fi
    kill -0 $(cat /var/run/rumal-fdaemon.pid)
    if [ $? -eq 1 ]; then
        /usr/bin/python /opt/rumal/manage.py fdaemon >/var/log/rumal-fdaemon.log 2>&1 &
        echo $! > /var/run/rumal-fdaemon.pid
    fi
    kill -0 $(cat /var/run/rumal-enrich.pid)
    if [ $? -eq 1 ]; then
        /usr/bin/python /opt/rumal/manage.py enrich >/var/log/rumal-enrich.log 2>&1 &
        echo $! > /var/run/rumal-enrich.pid
    fi
    sleep 60
done
