#!/bin/bash
server_list=('production.civpyhkigzas.us-east-1.rds.amazonaws.com' 'reader-bi.civpyhkigzas.us-east-1.rds.amazonaws.com' 'reader-primary.civpyhkigzas.us-east-1.rds.amazonaws.com' 'production-services-instance-1.civpyhkigzas.us-east-1.rds.amazonaws.com')
port=3306
limit=300
count=1

if [ -z ${1} ]; then
        left=50
else
        left=${1}
fi


while true;
do
    echo -e "\e[1m\e[36m" 
    echo $(date)
    
    for (( i=0; i<${#server_list[@]}; i++ )); 
        do
        c=$((33+$i+$i))
        echo -e "\e[1m\e["$c"m" | tr -d '\n'  
        server=${server_list[$i]}
        server_label=`echo ${server_list[$i]} | cut -d'.' -f1`
        echo ""
        echo $server_label
        #echo $server
        mysql  --protocol=tcp  --host=$server -P $port -e "select ID,DB,Host,User,Command,Time,State,left(Info,$left) as Query from information_schema.processlist where Command not in ('Binlog Dump','Sleep','Connect','Daemon') and Time > 0 order by time desc limit $limit; set @count = (select count(*) as count from information_schema.processlist where Command not in ('Sleep','Daemon') and Time > 0); " 
        if [[ $server_label == "production-services-instance-1" ]]; then
            mysql  --protocol=tcp  --host=$server -P $port -e "select user,count(1) as Count from information_schema.processlist where user not in ('financial_integration','bank_api','smb_payments_service','smb_payments_service_worker','smb_accounting_service','business_service','cashflow_enrichment','smb_invoices_service','smb_notifications','business_service_worker','kdavey','event_scheduler','rdsadmin','unauthenticated user','lendio_lake') group by user limit 10";
        fi
        if [[ $server_label == "production" ]]; then
            echo -e "\e[1m\e[31m"  | tr -d '\n'
            mysql  --protocol=tcp  --host=$server -P $port -e "select id,user,count(1) as Count from information_schema.processlist where user not in ('greedo','kdavey','event_scheduler','rdsadmin','unauthenticated user','lendio_lake') group by user limit 10";
            # Show counts of loaded borrower Assignments
            echo -e "\e[1m\e[33m"
            mysql  --protocol=tcp  --host=$server -P $port -e "select bab.bulkAssignmentid,bab.status,count(1) as Reassignmnets from optimus.bulkAssignmentBorrowers bab join optimus.bulkAssignments ba on bab.bulkAssignmentId = ba.id where bab.created > DATE_SUB(NOW(), INTERVAL 2 HOUR) and ba.deleted is NULL group by bab.status,bab.bulkAssignmentid order by bab.bulkAssignmentid;"
            echo -e "\e[1m\e["$c"m" | tr -d '\n'
                    mysql  --protocol=tcp  --host=$server -P $port -e "SELECT
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
        order by count(1) desc; select substring_index(host, ':', 1) as IP , count(*) from information_schema.processlist group by substring_index(host, ':', 1);" 
    
        fi

        #Show logins from IP Addresses

    done
    sleep 2;
done

