#!/bin/bash
server='production.civpyhkigzas.us-east-1.rds.amazonaws.com'
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
        echo -e "\e[1m\e[36m"
        qps=$(mysql  --protocol=tcp  --host=$server -P $port  -e '\s' | grep Threads | awk -F " " '{print $NF}')
        echo $(date) " - QPS " $qps
        mysql  --protocol=tcp  --host=$server -P $port -e "select ID,DB,Host,User,Command,Time,left(Info,$left) as Query, right(Info,20) as QueryEnd from information_schema.processlist where Command not in ('Binlog Dump','Sleep','Connect','Daemon') and Time > 0 order by time desc limit $limit; set @count = (select count(*) as count from information_schema.processlist where Command not in ('Sleep','Daemon') and Time > 0); " 
        # Show logged in user information
        #mysql  --protocol=tcp  --host=$server -P $port -e "set @count2 = (select count(*) as count from information_schema.processlist); set @count3 = (select count(*) as count from information_schema.processlist where User = 'greedo'); set @count4 = (select count(*) as count from information_schema.processlist where user = 'yoda'); set @count5 = (select count(*) as count from information_schema.processlist where user = 'tenant_write'); select @count as Running,@count2 as Connected,@count3 as greedo,@count4 as yoda,@count5 as tenant_write; select DB,User, count(*) as Count from information_schema.processlist where  Command not in ('Binlog Dump','Sleep','Daemon') group by DB, User order by count(*) limit 5; "

        #Show logins from IP Addresses
        # mysql  --protocol=tcp  --host=$server -P $port -e "SELECT
        # concat('CALL mysql.rds_kill(',b.trx_mysql_thread_id,');') as Commands,
        # count(1) as count
        # FROM information_schema.innodb_lock_waits w
        # INNER JOIN information_schema.innodb_trx b
        # ON b.trx_id = w.blocking_trx_id
        # INNER JOIN information_schema.innodb_trx r
        # ON r.trx_id = w.requesting_trx_id
        # where b.trx_query is NULL
        # group by b.trx_mysql_thread_id 
        # having count(1) > 3
        # order by count(1) desc; select substring_index(host, ':', 1) as IP , count(*) from information_schema.processlist group by substring_index(host, ':', 1);"
        
        # Show counts of loaded borrower Assignments
        echo -e "\e[1m\e[33m"
        mysql  --protocol=tcp  --host=$server -P $port -e "select bab.bulkAssignmentid,bab.status,count(1) as Reassignmnets from optimus.bulkAssignmentBorrowers bab join optimus.bulkAssignments ba on bab.bulkAssignmentId = ba.id where bab.created > DATE_SUB(NOW(), INTERVAL 2 HOUR) and ba.deleted is NULL group by bab.status,bab.bulkAssignmentid;"
        # Show deadlock info
        #echo -e "\e[1m\e[31m"
        #mysql  --protocol=tcp  --host=$server -P $port -e "select * from datateam.parker1\G";
        echo -e "\e[1m\e[36m"
       
        sleep 2;
        let count=count+1




done



  `borrowers`.`id`,
  `borrowers`.`applicationComplete`,
  `borrowers`.`created`,
  `borrowers`.`jumpballModified`,
  `borrowers`.`leadMedium`,
  `borrowers`.`leadSource`,
  `borrowers`.`mineralGroup`,
  `borrowers`.`name`,
  `borrowers`.`pppAppComplete`,
  `borrowers`.
  :