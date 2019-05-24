#!/bin/bash

echo "wget http://www.inet.no/dante/files/dante-1.4.2.tar.gz"
wget http://www.inet.no/dante/files/dante-1.4.2.tar.gz


echo "build dante"
tar xzvf dante-1.4.2.tar.gz
cd dante-1.4.2
./configure --prefix=/usr/local/dante
make 
make install

echo "install ok"

local_ip=`ifconfig | grep inet | grep -v "127.0.0.1" | awk '{print $2}'`

sockd_conf="
logoutput: /var/log/sockd.log          
debug: 1                               

internal: ${local_ip} port = 1081   #
external: eth0

user.notprivileged: sockd

clientmethod: none
method: none

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error # connect disconnect
}

pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bind connect udpassociate
        log: error # connect disconnect iooperation
}

pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bindreply udpreply
        log: error # connect disconnect iooperation
}
"

echo -e "${sockd_conf}" > sockd.conf

mv sockd.conf /etc/.

useradd sockd

/usr/local/dante/sbin/sockd  -D

echo "Sockd running ..."
