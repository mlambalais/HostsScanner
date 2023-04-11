#!/bin/bash

######################################################################################################################### DEBUG DHCP LEASES
dhclient >/dev/null 2>&1

######################################################################################################################### scan_hosts root directory
cd /var/scan_hosts/

######################################################################################################################### arp-scan
#arp-scan -I <NetInterfaceName> <subnet> > {export prompt in <filename>}
arp-scan -I ens18 192.168.0.0/24 > lan0
arp-scan -I ens19 192.168.1.0/24 > lan1
arp-scan -I ens20 192.168.2.0/24 > lan2
arp-scan -I ens21 192.168.3.0/24 > lan3

######################################################################################################################### Delete unwanted lines
# cat lanX | delete 2 first rows | delete 2 last rows > export in file
cat lan0 | head -n -3 | tail -n +3 > hosts
# cat lanX | delete 2 first rows | delete 2 last rows > append in file
cat lan1 | head -n -3 | tail -n +3 >> hosts
cat lan2 | head -n -3 | tail -n +3 >> hosts
cat lan3 | head -n -3 | tail -n +3 >> hosts

######################################################################################################################### ADD UP STATUS
# sed -i (inline) s:substitute $:each lines \t: tabulation(to respect the file format) 1: Host is UP (in my DB)
sed -i 's/$/\t1/' hosts

######################################################################################################################### MYSQL
DB_USER='your_mysql_user';
DB_PASSWD='your_mysql_pass';
DB_NAME='your_mysql_DB';

# update column UP to 0 (host is down)
mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME -e"UPDATE scan SET UP = '0'"

# delete all rown in the temp_scan table (used to import data"
mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME -e"DELETE FROM temp_scan"

# load data from file into temp_scan table
mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME --local_infile=1 -e"LOAD DATA LOCAL INFILE '/var/scan_hosts/hosts'
INTO TABLE temp_scan
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'"

# insert into scan table values from temp_scan table (and update values on duplicate entry)
mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME -e"INSERT INTO scan
SELECT * FROM temp_scan
ON DUPLICATE KEY UPDATE IP = VALUES(IP), MAC = VALUES(MAC), MACvendor = VALUES(MACvendor), UP = VALUES(UP)
"
