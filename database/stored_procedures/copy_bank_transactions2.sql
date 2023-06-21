-- CREATE TABLE `orgs2Move` (
--   `id` int unsigned NOT NULL AUTO_INCREMENT,
--   `organizationId` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
--   `cnt` int unsigned DEFAULT NULL,
--   `complete` tinyint unsigned DEFAULT NULL,
--   PRIMARY KEY (`id`),
--   KEY `organizationId_idx` (`id`,`organizationId`) USING BTREE
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci



-- insert into bank_service.orgs2Move (organizationId,cnt)
-- select distinct(organizationId), count(1) as cnt from bank_service.transactions t
--  where NOT EXISTS (
--      select NULL from bank_service.organizationJoin j
--          WHERE t.organizationId = j.organizationId)
--      group by organizationId
--      order by cnt desc;


-- call `datateam`.`copy_bank_transactions2`(26903,5,1)


DROP PROCEDURE IF EXISTS `datateam`.`copy_bank_transactions2`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`copy_bank_transactions2`(instart int, inIncrement int, maxLoops int)
proc_Exit:BEGIN
DECLARE loop_id int DEFAULT 1;
DECLARE total_loops int;
DECLARE loop_id_start int DEFAULT 1;
DECLARE loop_id_end int DEFAULT 1;
DECLARE max_org_id int DEFAULT 1;
DECLARE min_org_id int DEFAULT 1;
DECLARE job_steps int DEFAULT 1;
DECLARE last_loop_time int DEFAULT 1;
DECLARE total_rows_to_update int DEFAULT 1;
SET job_steps = 1;

select max(id) into max_org_id from bank_service.orgs2Move;
select IFNULL(max(id),1) into min_org_id from bank_service.orgs2Move where `complete` IS NOT NULL;
call `datateam`.`job_log_start`("copy_bank_transactions2",job_steps,1,inIncrement,min_org_id,"Starting Job",@_log_id);
SET innodb_lock_wait_timeout = 600;
SET total_rows_to_update = ((max_org_id) - min_org_id);


IF maxLoops > 1 THEN
    SET total_loops = maxLoops;
ELSE
    SET total_loops = ceiling(total_rows_to_update/inIncrement);
END IF;

-- select CONCAT("Processing Orgs between ",min_org_id," and ",max_org_id," in ",total_loops," loops.");
-- Step 1

IF min_org_id > 1 THEN
    SET loop_id_start = min_org_id;
ELSE 
    SET loop_id_start = 1;
END IF;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
SET loop_id = 1;

INSERT_LOOP_1:WHILE loop_id <= total_loops DO
    select CURRENT_TIMESTAMP into @start_loop;

        #select CONCAT("Between ",loop_id_start," and ",loop_id_end);

    SET @sql = CONCAT('insert ignore into bank_service._transactions 
        (providerTransactionId,providerHash,providerid,transactionTimeStamp,`name`,description, note, providerCategory, providerMerchant, mxMerchant,mxCategoryName,mxCategoryType,manualCategoryName,manualCategoryType, amount, currencyId, providerAccountId, businessId,providerCustomerId, created)
        select 
        case when t.id like "finicity%" then REPLACE(t.id,"finicity-","") 
                    when t.id like "unit%" then REPLACE(t.id,"unit-","")
                    ELSE t.id
            END as `providerTransactionid`
        ,SHA2(CONCAT(REPLACE(REPLACE(t.id,"unit-",""),"finicity-",""),":",REPLACE(REPLACE(accountId,"unit-",""),"finicity-",""),":",REPLACE(REPLACE(c.id,"unit-",""),"finicity-",""),":",t.organizationId),256) as `providerHash`
        ,IF(SUBSTRING_INDEX(t.id, "-", 1) = "finicity",1,2) as `providerId`-- provider
        ,`datetime` as `transactionTimestamp`
        ,t.`name`      
        ,`description`
        ,`note`
        ,`category` as providerCategory
        ,`merchant` as `providerMerchant`
        ,mxMerchant
        ,mxCategoryName
        ,mxCategoryType
        ,manualCategoryName
        ,manualCategoryType
        ,amount
        ,IF(t.currency = "USD",1,2) as `currencyId`
        ,REPLACE(REPLACE(accountId,"unit-",""),"finicity-","") as `providerAccountid`
        ,t.organizationId as `businessId`
        ,REPLACE(REPLACE(c.id,"unit-",""),"finicity-","") as `providerCustomerId`
        ,t.createdAt as `created`
            from bank_service.transactions t
                join bank_service.customers c on t.organizationId = c.organizationId
                join bank_service.accounts a on t.accountId = a.id
                join bank_service.banks b on a.bankId = b.id
                join bank_service.orgs2Move j on t.organizationId = j.organizationId
                where b.customerId = c.id
                and j.id between ',loop_id_start,' and ',loop_id_end,';');
    PREPARE s1 FROM @sql;
    EXECUTE s1;
    -- select @sql;
    SET @sql2 = CONCAT('
            update bank_service.orgs2Move set `complete` = 1
            where id between ',loop_id_start,' and ',loop_id_end,';');
    PREPARE s2 FROM @sql2;
    EXECUTE s2;
    -- select @sql2;
    select CONCAT('Loop :',loop_id,' of ',total_loops, ' Start - ',loop_id_start,' End - ',loop_id_end) as LoopCounter;
    SET loop_id_start = loop_id_end + 1;
    SET loop_id_end = loop_id_end + inIncrement;
    SET loop_id = loop_id+1;
    call `datateam`.`job_log_update`("status",CONCAT(loop_id," of ",total_loops));
END WHILE INSERT_LOOP_1;
call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);
        
END;;
DELIMITER ;

