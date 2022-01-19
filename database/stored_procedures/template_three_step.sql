DROP PROCEDURE IF EXISTS `datateam`.`template`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`template`(instart int, inIncrement int)
proc_Exit:BEGIN
DECLARE loop_id int DEFAULT 1;
DECLARE total_loops int;
DECLARE loop_id_start int DEFAULT 1;
DECLARE loop_id_end int DEFAULT 1;
DECLARE max_bv_id int DEFAULT 1;
DECLARE job_steps int DEFAULT 1;
DECLARE last_loop_time int DEFAULT 1;
DECLARE total_rows_to_update int DEFAULT 1;
SET job_steps = 3;


-- Query to get the upper value to loop up to
-- select max(id) into max_bv_id from optimus.borrowerValues;
call `datateam`.`job_log_start`("stored proc name",job_steps,1,inIncrement,inStart,"Starting Job",@_log_id);

SET total_rows_to_update = ((max_bv_id) - inStart);
SET total_loops = ceiling(total_rows_to_update/inIncrement);

-- Step 1

call `datateam`.`job_log_update`("status","Running Step 1");
call `datateam`.`job_log_steps_start`(@_log_id,1,"The First Step",max_bv_id,inIncrement,inStart,max_bv_id,"Starting First Step",@_log_step_id);

IF inStart > 1 THEN
	SET loop_id_start = inStart;
ELSE 
  	SET loop_id_start = 1;
END IF;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
SET loop_id = 1;

INSERT_LOOP_1:WHILE loop_id <= total_loops DO
	select CURRENT_TIMESTAMP into @start_loop;
    SET @sql = CONCAT('1st Query to loop through');
	PREPARE s1 FROM @sql;
	EXECUTE s1;
	select CONCAT('Loop :',loop_id,' of ',total_loops) as LoopCounter;
    SET loop_id_start = loop_id_end;
    SET loop_id_end = loop_id_end + inIncrement; 
    SET loop_id = loop_id+1;
	-- SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
	call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
	call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
END WHILE INSERT_LOOP_1;
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Step 2

call `datateam`.`job_log_update`("status","Running Step 2");
call `datateam`.`job_log_steps_start`(@_log_id,2,"The Second Step",max_bv_id,inIncrement,inStart,max_bv_id,"Starting Second Step",@_log_step_id);

IF inStart > 1 THEN
	SET loop_id_start = inStart;
ELSE 
  	SET loop_id_start = 1;
END IF;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
SET loop_id = 1;

INSERT_LOOP_2:WHILE loop_id <= total_loops DO
        select CURRENT_TIMESTAMP into @start_loop;
        SET @sql = CONCAT('2nd Query to loop through');
		PREPARE s1 FROM @sql;
		EXECUTE s1;
		select CONCAT('Loop :',loop_id,' of ',total_loops) as LoopCounter;
		SET loop_id_start = loop_id_end;
		SET loop_id_end = loop_id_end + inIncrement; 
		SET loop_id = loop_id+1;
		SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
		call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
		call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
END WHILE INSERT_LOOP_2;
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Step 3

call `datateam`.`job_log_update`("status","Running Step 3");
call `datateam`.`job_log_steps_start`(@_log_id,3,"The Third Step",max_bv_id,inIncrement,inStart,max_bv_id,"Starting Third Step",@_log_step_id);

IF inStart > 1 THEN
	SET loop_id_start = inStart;
ELSE 
  	SET loop_id_start = 1;
END IF;
SET loop_id_end = (loop_id_start - 1) + inIncrement;
SET loop_id = 1;

INSERT_LOOP_3:WHILE loop_id <= total_loops DO
        select CURRENT_TIMESTAMP into @start_loop;
        SET @sql = CONCAT('3rd Query to loop through.');
        		PREPARE s1 FROM @sql;
				EXECUTE s1;
        
        		select CONCAT('Loop :',loop_id,' of ',total_loops) as LoopCounter;
        		SET loop_id_start = loop_id_end;
        		SET loop_id_end = loop_id_end + inIncrement; 
         		SET loop_id = loop_id+1;
				SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
		call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
		call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
END WHILE INSERT_LOOP_3; 
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Finish things up

call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);
        
END;;
DELIMITER ;