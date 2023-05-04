DROP PROCEDURE IF EXISTS `datateam`.`copy_bank_transactions`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`copy_bank_transactions`(instart int, inIncrement int)
proc_Exit:BEGIN
DECLARE loop_id int DEFAULT 1;
DECLARE total_loops int;
DECLARE loop_id_start int DEFAULT 1;
DECLARE loop_id_end int DEFAULT 1;
DECLARE max_org_id int DEFAULT 1;
DECLARE job_steps int DEFAULT 1;
DECLARE last_loop_time int DEFAULT 1;
DECLARE total_rows_to_update int DEFAULT 1;
SET job_steps = 1;

select max(id) into max_org_id from bank_service.organizationJoin;
call `datateam`.`job_log_start`("copy_bank_transactions",job_steps,1,inIncrement,inStart,"Starting Job",@_log_id);

SET total_rows_to_update = ((max_org_id) - inStart);
SET total_loops = ceiling(total_rows_to_update/inIncrement);


-- Step 1

IF inStart > 1 THEN
    SET loop_id_start = inStart;
ELSE 
    SET loop_id_start = 1;
END IF;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
SET loop_id = 1;

INSERT_LOOP_1:WHILE loop_id <= total_loops DO
    select CURRENT_TIMESTAMP into @start_loop;


    SET @sql = CONCAT('insert into bank_service._transactions 
        (providerTransactionId,providerHash,providerid,transactionTimeStamp,`name`,description, note, providerCategory, providerMerchant, mxMerchant,mxCategoryName,mxCategoryType,manualCategoryName,manualCategoryType, amount, currencyId, providerAccountId, businessId,providerCustomerId, created)
        select 
        case when t.id like "finicity%" then REPLACE(t.id,"finicity-","") 
                    when t.id like "unit%" then REPLACE(t.id,"unit-","")
                    ELSE t.id
            END as `providerTransactionid`
        ,SHA2(CONCAT(REPLACE(REPLACE(t.id,"unit-",""),"finicity-",""),":",REPLACE(REPLACE(accountId,"unit-",""),"finicity-",""),":",REPLACE(REPLACE(c.id,"unit-",""),"finicity-",""),":",t.organizationId),256) as `providerHash`
        ,IF(SUBSTRING_INDEX(t.id, "-", 1) = "finicity",1,2) as `providerId`-- provider
        ,`datetime` as `transactionTimestamp`
        ,`name`      
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
        ,createdAt as `created`
            from bank_service.transactions t
                join bank_service.customers c on t.organizationId = c.organizationId and c.deletedAt is NULL
                join bank_service.organizationJoin j on t.organizationId = j.organizationId
                where j.id between ',loop_id_start,' and ',loop_id_end,';');
    -- PREPARE s1 FROM @sql;
    -- EXECUTE s1;
    select @sql;
    select CONCAT('Loop :',loop_id,' of ',total_loops) as LoopCounter;
    SET loop_id_start = loop_id_end;
    SET loop_id_end = loop_id_end + inIncrement; 
    SET loop_id = loop_id+1;
    -- SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
    -- call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
    -- call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
END WHILE INSERT_LOOP_1;
-- call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);
call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);
        
END;;
DELIMITER ;
