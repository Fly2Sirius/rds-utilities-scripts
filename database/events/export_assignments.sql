DROP EVENT IF EXISTS `datateam`.`export_assignments`;

DELIMITER ;;

CREATE EVENT `datateam`.`export_assignments` ON SCHEDULE EVERY 10 MINUTE STARTS '2023-02-03 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Dumps borrowers and assignments tables to S3' DO BEGIN

call datateam.log('export_assignments','start');

SELECT id as borrower_id FROM optimus.borrowers where userId = 10282184
INTO OUTFILE S3 "s3-us-east-1://lendio-lake-prd/snowflake_ingestion/borrower_assignment/borrowers"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;
SELECT
    borrowerId
    , created
    , oldLenderUserId
    , newLenderUserId
FROM optimus.assignments 
WHERE created >= date_add(CURRENT_TIMESTAMP, INTERVAL -24 HOUR) and (oldLenderUserId = 10282184 or newLenderUserId = 10282184)
INTO OUTFILE S3 "s3-us-east-1://lendio-lake-prd/snowflake_ingestion/borrower_assignment/assignments"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;

call datateam.log(NULL,'end');
END;;
DELIMITER ;