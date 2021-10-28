DROP PROCEDURE IF EXISTS `datateam`.`backfill-2021-10-27-set-borrowerValues_sourceId`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`backfill-2021-10-27-set-borrowerValues_sourceId`(inLimit int)
proc_Exit:BEGIN
DECLARE recordId tinyint;
DECLARE loopId int DEFAULT 1;
DECLARE total_loops int;
SET @inLimit = inLimit;
SET @userId = 1;
select count(distinct(createdByUserId)) into @total_rows from optimus.borrowerValues where createdByUserId is not NULL;
SET @sql = CONCAT('INSERT INTO datateam.`sp_logger` (`id`, `script`,total_rows_to_update,`limit`) VALUES (NULL,"backfill_source_id",',@total_rows,',',inLimit,');');
-- select @sql;
SET recordId = LAST_INSERT_ID();
PREPARE s1 FROM @sql;
EXECUTE s1;

    GET_USER_LOOP: while @userId != 0 DO
        SET @userId = 0;
        select CURRENT_TIMESTAMP into @start_loop;  
        select createdByUserId into @userId from optimus.borrowerValues where sourceId = 1 and createdByUserId is NOT NULL order by createdByUserId limit 1;
        select count(*) into @userIdCount from  optimus.borrowerValues where sourceId = 1 and createdByUserId = @userId;

        IF (select count(1) from optimus.lenders where id = @userId and isSystemAccount = 1) = 1 THEN 
            SET @sourceId = 6;
        ELSEIF (select count(1) from optimus.users where id = @userId and role = 'client') =1 THEN
            SET @sourceId = 2;
        ELSE
            SET @sourceId = 5;
		END IF;
        select count(*) into @userIdCount from  optimus.borrowerValues where sourceId = 1 and createdByUserId = @userId;

        IF @userIdCount > 1000 THEN
            SET loopId = 1;
            SET total_loops = (select @userIdCount/inLimit);
            UPDATE_SOURCE_LOOP:while loopId < total_loops DO
                
                SET @sql = CONCAT('update optimus.borrowerValues set sourceId = @sourceId where createdByUserId = @userId and sourceId = 1 limit ',inLimit,';');
                select @sql;
                
                SET loopId = loopId+1;
            END WHILE UPDATE_SOURCE_LOOP;
        ELSE 
            update optimus.borrowerValues set sourceId = @sourceId where createdByUserId = @userId and sourceId = 1;
        END IF;
        SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into @loop_time;
        SET @sql_update_log = CONCAT('update datateam.`sp_logger` set `completed_loops` = (`completed_loops` + 1), loop_time = ',@loop_time,' where id = ',recordId);     
        -- select @sql_update_log;
		PREPARE s1 FROM @sql_update_log;
		EXECUTE s1;
    END WHILE GET_USER_LOOP;
END;;
DELIMITER ;
