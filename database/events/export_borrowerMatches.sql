DROP EVENT IF EXISTS `datateam`.`export_borrowerMatches`;

DELIMITER ;;

CREATE EVENT `datateam`.`export_borrowerMatches` ON SCHEDULE EVERY 10 MINUTE STARTS '2021-11-23 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Dumps borrowerMatches table to S3' DO BEGIN
	call datateam.log('export_borrowerValues','start');
	
SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

create temporary table _borrowerMatchIds as       
	SELECT distinct borrowerId
	FROM optimus.borrowerMatches
	WHERE created > DATE_SUB(NOW(), INTERVAL '1' HOUR);


SELECT CONCAT('
SELECT borrowerId
    , MAX(CASE WHEN value = "accepted" THEN borrowerClassificationId END) AS borrowerClassificationId_Accepted
    , MAX(CASE WHEN value = "partial" THEN borrowerClassificationId END) AS borrowerClassificationId_Partial
    , MAX(CASE WHEN value = "potential" THEN borrowerClassificationId END) AS borrowerClassificationId_Potential
    , MAX(CASE WHEN value = "rejected" THEN borrowerClassificationId END) AS borrowerClassificationId_Rejected
    , MAX(CASE WHEN value = "accepted" THEN loanProductCategoryId END) AS loanProductCategoryId_Accepted
    , MAX(CASE WHEN value = "partial" THEN loanProductCategoryId END) AS loanProductCategoryId_Partial
    , MAX(CASE WHEN value = "potential" THEN loanProductCategoryId END) AS loanProductCategoryId_Potential
    , MAX(CASE WHEN value = "rejected" THEN loanProductCategoryId END) AS loanProductCategoryId_Rejected
    , MAX(CASE WHEN value = "accepted" THEN loanProductId END) AS loanProductId_Accepted
    , MAX(CASE WHEN value = "partial" THEN loanProductId END) AS loanProductId_Partial
    , MAX(CASE WHEN value = "potential" THEN loanProductId END) AS loanProductId_Potential
    , MAX(CASE WHEN value = "rejected" THEN loanProductId END) AS loanProductId_Rejected
    , CURRENT_TIMESTAMP as last_updated
FROM (
    SELECT bm.borrowerId, bm.value
	    , GROUP_CONCAT(bm.borrowerClassificationId SEPARATOR ", ") AS borrowerClassificationId
        , GROUP_CONCAT(bm.loanProductCategoryId SEPARATOR ", ") AS loanProductCategoryId
        , GROUP_CONCAT(bm.loanProductId SEPARATOR ", ") AS loanProductId
        FROM optimus.borrowerMatches bm
    join _borrowerMatchIds bm2 on bm.borrowerId = bm2.borrowerId
    group by bm.borrowerId, bm.value
) ConcatTable
GROUP BY borrowerId
INTO OUTFILE S3 "s3-us-east-1://lendio-lake-prd/snowflake_ingestion/borrower_matches/borrowerMatches_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP temporary table _borrowerMatchIds;

call datateam.log(NULL,'end');
END;;
DELIMITER ;