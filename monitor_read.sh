#!/bin/bash
#server='reader-primary.civpyhkigzas.us-east-1.rds.amazonaws.com'
##server='application-autoscaling-c9cd010c-5273-416d-87b6-99f6d7e62f84.civpyhkigzas.us-east-1.rds.amazonaws.com'
server='reader-bi.civpyhkigzas.us-east-1.rds.amazonaws.com'
port=3306
limit=30
count=1

echo "Monitoring $server"
sleep 1.5
if [ -z ${1} ]; then
        left=50
else
        left=${1}
fi
while [ $count -le 10000 ]
do
        date
        mysql  --protocol=tcp  --host=$server -P $port -e "select ID,DB,User,Command,Time,left(Info,$left) as Query, right(Info,22) as QueryEnd from information_schema.processlist where Command not in ('Binlog Dump','Sleep','Daemon') and Time > 0 order by time desc limit $limit; set @count = (select count(*) as count from information_schema.processlist where Command not in ('Sleep','Daemon') and Time > 0); set @count2 = (select count(*) as count from information_schema.processlist); set @count3 = (select count(*) as count from information_schema.processlist where User = 'srabbit'); set @count4 = (select count(*) as count from information_schema.processlist where user = 'Srabbitdl'); set @count5 = (select count(*) as count from information_schema.processlist where user = 'Srabbitapi'); set @count6 = (select count(*) as count from information_schema.processlist where user = 'Srabbitjob'); select @count as Running,@count2 as Connected,@count3 as srabbit,@count4 as srabbitdl,@count5 as srabbitiapi,@count6 as srabbitjob; select DB,User, count(*) as Count from information_schema.processlist where User != 'kdavey' and Command not in ('Binlog Dump','Sleep','Daemon') group by DB, User order by count(*) limit 5; select substring_index(host, ':', 1) as IP , count(*) from information_schema.processlist group by substring_index(host, ':', 1);";
        sleep 2;
        let count=count+1
done
