DROP EVENT IF EXISTS `datateam`.`export_borrowerMatchesSplit`;

DELIMITER ;;

CREATE EVENT `datateam`.`export_borrowerMatchesSplit` ON SCHEDULE EVERY 10 MINUTE STARTS '2023-02-03 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Dumps 3 borrowerMatches tables to S3' DO BEGIN

call datateam.log('export_borrowerValuesSplit','start');
    
SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

drop temporary table if exists datateam._borrowerMatchIds;

create temporary table datateam._borrowerMatchIds as       
select distinct(borrowerId) from (
select borrowerId FROM optimus.borrowerMatchesClassifications
WHERE created > DATE_SUB(NOW(), INTERVAL '1' HOUR)
union
select borrowerId FROM optimus.borrowerMatchesLoanProducts
WHERE created > DATE_SUB(NOW(), INTERVAL '1' HOUR)
union
select borrowerId FROM optimus.borrowerMatchesLoanProductCategories 
WHERE created > DATE_SUB(NOW(), INTERVAL '1' HOUR)
)x;

drop table if exists datateam.borrowerClassifications;

create table datateam.borrowerClassifications as
SELECT borrowerId
, MAX(CASE WHEN value = "accepted" THEN borrowerClassificationId END) AS borrowerClassificationId_Accepted
, MAX(CASE WHEN value = "partial" THEN borrowerClassificationId END) AS borrowerClassificationId_Partial
, MAX(CASE WHEN value = "potential" THEN borrowerClassificationId END) AS borrowerClassificationId_Potential
, MAX(CASE WHEN value = "rejected" THEN borrowerClassificationId END) AS borrowerClassificationId_Rejected
FROM (
     SELECT bmc.borrowerId, l.value
        , GROUP_CONCAT(bmc.itemId SEPARATOR ", ") AS borrowerClassificationId
        FROM optimus.borrowerMatchesClassifications bmc
    join datateam._borrowerMatchIds bm2 on bmc.borrowerId = bm2.borrowerId
    left join optimus.borrowerMatchesValueLookup l on bmc.valueId = l.id
    group by bmc.borrowerId, l.value
) ConcatTable
GROUP BY borrowerId;

drop table if exists datateam.borrowerLoanProductCategory;

create table datateam.borrowerLoanProductCategory as
SELECT borrowerId
, MAX(CASE WHEN value = "accepted" THEN loanProductCategoryId END) AS loanProductCategoryId_Accepted
, MAX(CASE WHEN value = "partial" THEN loanProductCategoryId END) AS loanProductCategoryId_Partial
, MAX(CASE WHEN value = "potential" THEN loanProductCategoryId END) AS loanProductCategoryId_Potential
, MAX(CASE WHEN value = "rejected" THEN loanProductCategoryId END) AS loanProductCategoryId_Rejected
FROM (
     SELECT bmlp.borrowerId, l.value
        , GROUP_CONCAT(bmlp.itemId SEPARATOR ", ") AS loanProductCategoryId
        FROM optimus.borrowerMatchesLoanProductCategories bmlp
    join datateam._borrowerMatchIds bm2 on bmlp.borrowerId = bm2.borrowerId
    left join optimus.borrowerMatchesValueLookup l on bmlp.valueId = l.id
    group by bmlp.borrowerId, l.value
) ConcatTable
GROUP BY borrowerId;

set session group_concat_max_len=18446744073709551615;

drop table if exists datateam.borrowerLoanProducts;

create table datateam.borrowerLoanProducts as
SELECT borrowerId
, MAX(CASE WHEN value = "accepted" THEN loanProductId END) AS loanProductId_Accepted
, MAX(CASE WHEN value = "partial" THEN loanProductId END) AS loanProductId_Partial
, MAX(CASE WHEN value = "potential" THEN loanProductId END) AS loanProductId_Potential
, MAX(CASE WHEN value = "rejected" THEN loanProductId END) AS loanProductId_Rejected
FROM (
     SELECT bmlp.borrowerId, l.value
        , GROUP_CONCAT(bmlp.itemId SEPARATOR ", ") AS loanProductId
        FROM optimus.borrowerMatchesLoanProducts bmlp
    join datateam._borrowerMatchIds bm2 on bmlp.borrowerId = bm2.borrowerId
    left join optimus.borrowerMatchesValueLookup l on bmlp.valueId = l.id
    group by bmlp.borrowerId, l.value
) ConcatTable
GROUP BY borrowerId;

SELECT CONCAT('
select
    bc.borrowerId
    ,bc.borrowerClassificationId_Accepted
    ,bc.borrowerClassificationId_Partial
    ,bc.borrowerClassificationId_Potential
    ,bc.borrowerClassificationId_Rejected
    ,blpc.loanProductCategoryId_Accepted
    ,blpc.loanProductCategoryId_Partial
    ,blpc.loanProductCategoryId_Potential
    ,blpc.loanProductCategoryId_Rejected
    ,blp.loanProductId_Accepted
    ,blp.loanProductId_Partial
    ,blp.loanProductId_Potential
    ,blp.loanProductId_Rejected
    ,CURRENT_TIMESTAMP as last_updated
    from datateam.borrowerLoanProductCategory blpc
left join datateam.borrowerClassifications bc on blpc.borrowerId = bc.borrowerId
left join datateam.borrowerLoanProducts blp on blpc.borrowerId = blp.borrowerId
INTO OUTFILE S3 "s3-us-east-1://lendio-lake-prd/snowflake_ingestion/borrower_matchesSplit/borrowerMatches_',@timestamp,'"  
    FIELDS TERMINATED BY "\\t" 
    LINES TERMINATED BY "\\n"
    OVERWRITE ON;') into @sql;

PREPARE stmt from @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP temporary table datateam._borrowerMatchIds;

call datateam.log(NULL,'end');
END;;
DELIMITER ;