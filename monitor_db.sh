#!/bin/bash
server='scrub-18141.civpyhkigzas.us-east-1.rds.amazonaws.com'
port=3306
limit=30
count=1
user=root
password=NPZBHNaC82CSozqjJi37HXXKelGh60EyHNcdMY96
if [ -z ${1} ]; then
        left=50
else
        left=${1}
fi
while [ $count -le 100000 ]
do
        date
        mysql  --protocol=tcp  --host=$server  -P $port -uroot -p$password -e "select ID,DB,User,Command,Time,left(Info,$left) as Query from information_schema.processlist where Command not in ('Binlog Dump','Sleep','Daemon') and Info not like 'select ID,DB,User,Command,Time,%' order by time desc limit $limit; set @count = (select count(*) as count from information_schema.processlist where Command not in ('Sleep','Daemon') and Time > 0);¡ set @count2 = (select count(*) as count from information_schema.processlist); set @count3 = (select Variable_value from sys.metrics where Variable_name = 'Questions'); set @count4 = (select Variable_value from sys.metrics where Variable_name = 'Queries'); set @count5 = (select SUM(VARIABLE_VALUE) from information_schema.GLOBAL_STATUS where VARIABLE_NAME in ('COM_INSERT','COM_UPDATE','COM_DELETE','COM_INSERT_SELECT'));set @count5 = (select SUM(VARIABLE_VALUE) from information_schema.GLOBAL_STATUS where VARIABLE_NAME in ('COM_SELECT')); select @count as Running,@count2 as Connected,@count3 as Questions, @count4 as Queries, @count5 as CRUD,@count6 as SELECTS; "; 
        sleep 1;
        let count=count+1
done
