DROP EVENT IF EXISTS `datateam`.`export_borrower_data`;

DELIMITER ;;

CREATE EVENT `datateam`.`export_borrower_data` ON SCHEDULE EVERY 5 MINUTE STARTS '2023-09-21 01:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Dumps 5 borrower related tables every 5 minutes to S3' DO BEGIN

SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));
SET @job_steps = 0;
call `datateam`.`job_log_start`("Export Borrower Data",@job_steps,1,0,0,"Starting Job",@_log_id);

SELECT CONCAT('
select id
, name
, userid
, clientid
, stage
, status
, created
, modified
, zeeid
, deleted
, borrowerclassificationids
from optimus.borrowers
where isTest = 0
and modified > NOW() - INTERVAL 6 MINUTE
INTO OUTFILE S3 "s3-us-east-1://lendio-snowflake-exports/borrower_data/borrowers/borrowers_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT CONCAT('
select t.borrowerid
, t.created
, t.modified
, t.deleted
from optimus.doNotContactEmails t
join optimus.borrowers b on t.borrowerId = b.id
where t.modified > NOW() - INTERVAL 6 MINUTE
and b.isTest = 0
INTO OUTFILE S3 "s3-us-east-1://lendio-snowflake-exports/borrower_data/donotcontactemails/doNotContactEmails_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT CONCAT('
select t.borrowerid
, t.created
, t.modified
, t.deleted
from optimus.doNotContactPhones t
join optimus.borrowers b on t.borrowerId = b.id
where t.modified > NOW() - INTERVAL 6 MINUTE
and b.isTest = 0
INTO OUTFILE S3 "s3-us-east-1://lendio-snowflake-exports/borrower_data/donotcontactphones/doNotContactPhones_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT CONCAT('
select t.borrowerid
, t.type
, t.started
, t.completed
, t.created
, t.modified
, t.deleted
from optimus.borrowerApplications t
join optimus.borrowers b on t.borrowerId = b.id
where t.modified > NOW() - INTERVAL 6 MINUTE
and b.isTest = 0
INTO OUTFILE S3 "s3-us-east-1://lendio-snowflake-exports/borrower_data/borrowerapplications/borrowerApplications_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT CONCAT('
select t.borrowerid
, t.attributeid
, t.value
, t.created
, t.modified
from optimus.borrowerValues t
join optimus.borrowers b on t.borrowerId = b.id
where t.modified > NOW() - INTERVAL 6 MINUTE
and b.isTest = 0
INTO OUTFILE S3 "s3-us-east-1://lendio-snowflake-exports/borrower_data/borrowervalues/borrowerValues_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


call `datateam`.`job_log_update`("errors",@@error_count);
call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END;;
DELIMITER ;