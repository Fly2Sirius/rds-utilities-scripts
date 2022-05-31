DROP PROCEDURE IF EXISTS `datateam`.`delete_old_apiLogs`;


DELIMITER ;;
CREATE PROCEDURE `datateam`.`delete_old_apiLogs`(inIncrement int)
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


select count(*) into max_temp_id from logs.apiLog where created < DATE_SUB(NOW(), INTERVAL 90 DAY);
call `datateam`.`job_log_start`("delete_old_apiLogs",job_steps,1,inIncrement,0,"Starting Job",@_log_id);
SET total_rows_to_update = max_temp_id;
SET total_loops = ceiling(total_rows_to_update/inIncrement);
-- select total_loops;
SET loop_id = 1;
call `datateam`.`job_log_steps_start`(@_log_id,1,"The First Step",max_temp_id,inIncrement,0,max_temp_id,"Deleting apiLogs",@_log_step_id);
call `datateam`.`job_log_steps_update`("rows_to_update",max_temp_id);
call `datateam`.`job_log_steps_update`("total_rows_to_update",max_temp_id);
    UPDATE_LOOP:WHILE loop_id <= total_loops DO
        select CURRENT_TIMESTAMP into @start_loop; 
        IF loop_id_end > max_temp_id THEN
            SET loop_id_end = max_temp_id;
        END IF;
        SET @sql = CONCAT('delete from logs.apiLog where created < DATE_SUB(NOW(), INTERVAL 90 DAY) limit ',inIncrement,';');
        -- select @sql;
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
