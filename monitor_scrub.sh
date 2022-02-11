#!/bin/bash
server='scrub-1.civpyhkigzas.us-east-1.rds.amazonaws.com'
port=3306
limit=3000
count=1
password="agvWkCxP40GbDDGjcY96Xorfulaf17ZQBFIjxC53"
if [ -z ${1} ]; then
        left=50
else
        left=${1}
fi
while [ $count -le 10000 ]
do
        date
        mysql  --protocol=tcp  --host=$server --user root -p$password -P $port -e "select ID,DB,User,Command,Time,left(Info,$left) as Query, right(Info,20) as QueryEnd from information_schema.processlist where Command not in ('Binlog Dump','Sleep','Daemon') and Time > 0 order by time desc limit $limit; set @count = (select count(*) as count from information_schema.processlist where Command not in ('Sleep','Daemon') and Time > 0); set @count2 = (select count(*) as count from information_schema.processlist); set @count3 = (select count(*) as count from information_schema.processlist where User = 'greedo'); set @count4 = (select count(*) as count from information_schema.processlist where user = 'yoda'); set @count5 = (select count(*) as count from information_schema.processlist where user = 'tenant_write'); set @count6 = (select count(*) as count from information_schema.processlist where user = 'Srabbitjob'); select @count as Running,@count2 as Connected,@count3 as greedo,@count4 as yoda,@count5 as tenant_write,@count6 as srabbitjob; select DB,User, count(*) as Count from information_schema.processlist where  Command not in ('Binlog Dump','Sleep','Daemon') group by DB, User order by count(*) limit 5; ";
        sleep 2;
        let count=count+1
done
