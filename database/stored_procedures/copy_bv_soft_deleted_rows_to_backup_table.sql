DROP PROCEDURE `datateam`.`backfill_2021122_backup_soft_deleted_bvs`;

DELIMITER ;;
CREATE PROCEDURE `backfill_2021122_backup_soft_deleted_bvs`(inStart int, inIncrement int)
proc_Exit:BEGIN
DECLARE loop_id int DEFAULT 1;
DECLARE total_loops int;
DECLARE loop_id_start int DEFAULT 1;
DECLARE loop_id_end int DEFAULT 1;
DECLARE max_id int DEFAULT 1;
DECLARE min_id int DEFAULT 1;
DECLARE job_steps int DEFAULT 1;
DECLARE last_loop_time int DEFAULT 1;
DECLARE total_rows_to_update int DEFAULT 1;
DECLARE rows_updated int DEFAULT 0;
SET job_steps = 1;


select max(id) into max_id from optimus.borrowerValues;
select min(id) into min_id from optimus.borrowerValues;
select count(*) into total_rows_to_update from optimus.borrowerValues where deleted is NULL;
call `datateam`.`job_log_start`("backfill_2021122_backup_soft_deleted_bvs",job_steps,1,inIncrement,inStart,"Starting Job",@_log_id);
IF inStart > 1 THEN
	SET loop_id_start = inStart;
ELSE 
  	SET loop_id_start = min_id;
END IF;
SET total_loops = ceiling((max_id-loop_id_start)/inIncrement);
-- select total_loops;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
select max_id,inStart,total_rows_to_update,loop_id_end,total_loops;
SET loop_id = 1;
call `datateam`.`job_log_steps_start`(@_log_id,1,"The First Step",total_rows_to_update,inIncrement,inStart,max_id,"Starting First Step",@_log_step_id);
call `datateam`.`job_log_steps_update`("total_rows_to_update",total_rows_to_update);
	INSERT_LOOP:WHILE loop_id <= total_loops DO
	   	select CURRENT_TIMESTAMP into @start_loop; 
	   	IF loop_id_end > max_id THEN
	   		SET loop_id_end = max_id;
		END IF;
	   	SET @sql = CONCAT('
           INSERT INTO optimus._borrowerValuesSoftDeletedRows (
            bvId,
            borrowerId,
            attributeId,
            createdByUserId,
            updatedByUserId,
            documentId,
            sourceId,
            value,
            bvCreated,
            bvModified)
            SELECT
                id AS bvId,
                borrowerId,
                attributeId,
                createdByUserId,
                updatedByUserId,
                documentId,
                sourceId,
                value,
                created AS bvCreated,
                modified AS bvModified
            FROM optimus.borrowerValues
            WHERE deleted IS NOT NULL
            AND id BETWEEN ',loop_id_start,' and ',loop_id_end,';');
		-- select @sql;
	    PREPARE s1 FROM @sql;
		EXECUTE s1;
	        
	    select CONCAT('Loop :',loop_id,' of ',total_loops) as LoopCounter;
	    SET loop_id_start = loop_id_end;
	    SET loop_id_end = loop_id_end + inIncrement; 
	    SET loop_id = loop_id+1;
        -- SET rows_updated =  (select count(1) from optimus._borrowerValuesSoftDeletedRows);   
	    SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
	    call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
		call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
        -- call `datateam`.`job_log_steps_update`("rows_updated",rows_updated);
    END WHILE INSERT_LOOP;
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);
END;;
DELIMITER ;

CALL `datateam`.`backfill_2021122_backup_soft_deleted_bvs`(1, 10000);