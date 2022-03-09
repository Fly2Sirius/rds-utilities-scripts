DROP PROCEDURE IF EXISTS `datateam`.`backfill_2022_03_08_Delete_Expired_OAuth_Sessions`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`backfill_2022_03_08_Delete_Expired_OAuth_Sessions`(inStart int, inIncrement int)
proc_Exit:BEGIN
DECLARE loop_id int DEFAULT 1;
DECLARE total_loops int;
DECLARE loop_id_start int DEFAULT 1;
DECLARE loop_id_end int DEFAULT 1;
DECLARE max_temp_id int DEFAULT 1;
DECLARE job_steps int DEFAULT 1;
DECLARE last_loop_time int DEFAULT 1;
DECLARE total_rows_to_update int DEFAULT 1;
SET job_steps = 1;

select max(id) into max_temp_id from oauth.oauth_sessions;
call `datateam`.`job_log_start`("Delete Expired OAuth Sessions",job_steps,1,inIncrement,inStart,"Starting Job",@_log_id);
SET total_rows_to_update = ((max_temp_id) - inStart);
SET total_loops = ceiling(total_rows_to_update/inIncrement);
IF inStart > 1 THEN
	SET loop_id_start = inStart;
ELSE 
  	SET loop_id_start = 1;
END IF;
-- select total_loops;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
select max_temp_id,inStart,total_rows_to_update,loop_id_end,total_loops;
SET loop_id = 1;
call `datateam`.`job_log_steps_start`(@_log_id,1,"The First Step",max_temp_id,inIncrement,inStart,max_temp_id,"Starting First Step",@_log_step_id);
	UPDATE_LOOP:WHILE loop_id <= total_loops DO
	   	select CURRENT_TIMESTAMP into @start_loop; 
	   	IF loop_id_end > max_temp_id THEN
	   		SET loop_id_end = max_temp_id;
		END IF;
	   	SET @sql = CONCAT('delete os,osat from oauth.oauth_sessions os
	            join oauth.oauth_session_access_tokens osat on os.id = osat.session_id 
	            where osat.access_token_expires < unix_timestamp(current_timestamp)
	            and os.id between ',loop_id_start,' and ',loop_id_end,';');
		select @sql;
	    PREPARE s1 FROM @sql;
		EXECUTE s1;
	        
	    select CONCAT('Loop :',loop_id,' of ',total_loops) as LoopCounter;
	    SET loop_id_start = loop_id_end;
	    SET loop_id_end = loop_id_end + inIncrement; 
	    SET loop_id = loop_id+1;   
	    SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
	    call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
		call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
    END WHILE UPDATE_LOOP;
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);
END;;
DELIMITER ;