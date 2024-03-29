DROP PROCEDURE IF EXISTS `datateam`.`backfill_2021116_build_bv_sourceId_temp_table`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`backfill_2021116_build_bv_sourceId_temp_table`(instart int, inIncrement int)
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

select max(id) into max_bv_id from optimus.borrowerValues;
call `datateam`.`job_log_start`("build_bv_sourceId_temp_table",job_steps,1,inIncrement,inStart,"Starting Job",@_log_id);

SET total_rows_to_update = ((max_bv_id) - inStart);
SET total_loops = ceiling(total_rows_to_update/inIncrement);

CREATE TABLE IF NOT EXISTs `optimus`.`_temp_borrowerValue_sourceid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowerValueId` int(10) unsigned DEFAULT NULL,
  `sourceId` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unq` (`borrowerValueId`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



truncate table `optimus`.`_temp_borrowerValue_sourceid`;

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
    SET @sql = CONCAT('insert ignore into optimus._temp_borrowerValue_sourceid (borrowerValueId,sourceId)
        select bv.id,6 from optimus.borrowerValues bv
        join optimus.lenders l on bv.createdByUserId = l.id
        where l.isSystemAccount = 1
        -- and bv.deleted is NULL
		and bv.id between ',loop_id_start,' and ',loop_id_end,';');
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
        SET @sql = CONCAT('insert ignore into optimus._temp_borrowerValue_sourceid (borrowerValueId,sourceId)
            select bv.id,5 from optimus.borrowerValues bv
			join optimus.users u on bv.createdByUserId = u.id
			where u.role = "client"
			-- and bv.deleted IS NULL
			and bv.id between ',loop_id_start,' and ',loop_id_end,';');
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
        SET @sql = CONCAT('insert ignore into optimus._temp_borrowerValue_sourceid (borrowerValueId,sourceId)
				select bv.id,2 from optimus.borrowerValues bv
				where bv.createdByUserId is NOT NULL
				-- and bv.deleted is NULL
				and bv.id between ',loop_id_start,' and ',loop_id_end,';');
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

call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);
        
END;;
DELIMITER ;