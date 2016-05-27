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
usermod -aG docker root
/etc/init.d/docker start 

# Mongodb listening on interfaces
sed -i 's/^  bindIp: 127.0.0.1/  bindIp: 0.0.0.0,172.18.0.1,192.168.99.100,172.17.0.2/' /etc/mongod.conf


#Mongo db in background
/usr/bin/sudo /usr/bin/mongod --smallfiles --fork --logpath /var/log/mongod.log


#Pull thug
docker pull pdelsante/thug-dockerfile

echo "Starting Rumal's backend worker daemon..." 
/usr/bin/python /opt/rumal_back/manage.py run_thug >/var/log/rumal_back-run_thug.log 2>&1 &
echo $! > /var/run/rumal_back-run_thug.pid

echo "Starting Rumal's backend HTTP Server..."
/usr/bin/python /opt/rumal_back/manage.py runserver 0.0.0.0:8000 >/var/log/rumal_back-web.log 2>&1 &
echo $! > /var/run/rumal_back-http.pid

# Give a hint about how to use
echo "Running on: http://hostDockerIP:8000/"
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
    sleep 60
done
