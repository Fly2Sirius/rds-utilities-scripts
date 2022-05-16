#!/bin/bash
server='homeportal-rc.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com'
#server='recovery-production-1.civpyhkigzas.us-east-1.rds.amazonaws.com'
echo -e "\e[1m\e[36m"
port=3306
limit=300
count=1
if [ -z ${1} ]; then
        left=50
else
        left=${1}
fi
while [ $count -le 10000 ]
do
        date
        mysql  --protocol=tcp  --host=$server -P $port -e "select ID,DB,User,Command,Time,left(Info,$left) as Query, right(Info,20) as QueryEnd from information_schema.processlist where Command not in ('Binlog Dump','Sleep','Connect','Daemon') and Time > 0 order by time desc limit $limit; set @count = (select count(*) as count from information_schema.processlist where Command not in ('Sleep','Daemon') and Time > 0); set @count2 = (select count(*) as count from information_schema.processlist); set @count3 = (select count(*) as count from information_schema.processlist where User = 'greedo'); set @count4 = (select count(*) as count from information_schema.processlist where user = 'yoda'); set @count5 = (select count(*) as count from information_schema.processlist where user = 'tenant_write');  select @count as Running,@count2 as Connected,@count3 as greedo,@count4 as yoda,@count5 as tenant_write; select DB,User, count(*) as Count from information_schema.processlist where  Command not in ('Binlog Dump','Sleep','Daemon') group by DB, User order by count(*) limit 5; 
SELECT
concat('CALL mysql.rds_kill(',b.trx_mysql_thread_id,');') as Commands,
count(1) as count
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b
ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r
ON r.trx_id = w.requesting_trx_id
where b.trx_query is NULL
group by b.trx_mysql_thread_id 
having count(1) > 3
order by count(1) desc";
		sleep 2;
        let count=count+1
done
