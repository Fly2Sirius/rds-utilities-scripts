DROP PROCEDURE IF EXISTS `datateam`.`delete_borrowerValue_duplicates`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`delete_borrowerValue_duplicates`(inStart int, inIncrement int)
proc_Exit:BEGIN
DECLARE loop_id int DEFAULT 1;
DECLARE total_loops int;
DECLARE loop_id_start int DEFAULT 1;
DECLARE loop_id_end int DEFAULT 1;
DECLARE max_bv_id int DEFAULT 1;
DECLARE job_steps int DEFAULT 1;
DECLARE last_loop_time int DEFAULT 1;
DECLARE total_rows_to_update int DEFAULT 1;
SET job_steps = 4;


-- Query to get the upper value to loop up to
-- select max(id) into max_bv_id from optimus.borrowerValues;
call `datateam`.`job_log_start`("delete_borrowerValue_duplicates",job_steps,1,inIncrement,inStart,"Starting Job",@_log_id);

SET total_rows_to_update = ((max_bv_id) - inStart);
SET total_loops = ceiling(total_rows_to_update/inIncrement);

-- Step 1

call `datateam`.`job_log_update`("status","Running Step 1");
call `datateam`.`job_log_steps_start`(@_log_id,1,"The First Step",max_bv_id,inIncrement,inStart,max_bv_id,"Finding additional duplicates",@_log_step_id);
SET loop_id = 1;
select CURRENT_TIMESTAMP into @start_loop;
SET @sql = CONCAT('insert into optimus._duplicates (borrowerId,attributeId,documentId,sourceId,cnt)
	select * from (select borrowerId,attributeId,documentId,sourceId,count(*) cnt  from optimus.borrowerValues where id > ',inStart,' group by borrowerId,attributeId,documentId,sourceId having count(*) > 1) as dt
	on duplicate key update cnt = dt.cnt;');
PREPARE s1 FROM @sql;
EXECUTE s1;
call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
call `datateam`.`job_log_steps_update`("last_loop_time","Finished Step 1");
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Step 2

call `datateam`.`job_log_update`("status","Running Step 2");
call `datateam`.`job_log_update`("step_current","2");
call `datateam`.`job_log_steps_start`(@_log_id,2,"The Second Step",max_bv_id,inIncrement,inStart,max_bv_id,"Backing Up Duplicate borrowerValues",@_log_step_id);
SET loop_id = 1;
select CURRENT_TIMESTAMP into @start_loop;
SET @sql = CONCAT('insert ignore into optimus._duplicatesBackUp
	select bv.* from optimus.borrowerValues bv
	join optimus._duplicates d on bv.borrowerId = d.borrowerId and bv.attributeId = d.attributeId and bv.documentId = d.documentId and bv.sourceId = d.sourceId;');
PREPARE s1 FROM @sql;
EXECUTE s1;
SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
call `datateam`.`job_log_steps_update`("last_loop_time","Finished Step 2");
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Step 3

call `datateam`.`job_log_update`("status","Running Step 3");
call `datateam`.`job_log_update`("step_current","3");
call `datateam`.`job_log_steps_start`(@_log_id,3,"Loading _duplicatesToDelete table before deletion.",max_bv_id,inIncrement,inStart,max_bv_id,"Starting Third Step",@_log_step_id);
SET loop_id = 1;
select CURRENT_TIMESTAMP into @start_loop;
SET @sql = CONCAT('insert ignore into optimus._duplicatesToDelete
select t1.id from optimus._duplicatesBackUp t1
INNER JOIN optimus._duplicatesBackUp t2
WHERE t1.borrowerId = t2.borrowerId
AND t1.attributeId = t2.attributeId
AND t1.documentId = t2.documentId
AND t1.sourceId = t2.sourceId
AND t1.id < t2.id;');
PREPARE s1 FROM @sql;
EXECUTE s1;
SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
call `datateam`.`job_log_steps_update`("last_loop_time","Finished Step 3");
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Step 4

call `datateam`.`job_log_update`("status","Running Step 4");
call `datateam`.`job_log_update`("step_current","4");
call `datateam`.`job_log_steps_start`(@_log_id,4,"Deleting duplicate borrowerValues.",max_bv_id,inIncrement,inStart,max_bv_id,"Starting Fourth Step",@_log_step_id);
SET loop_id = 1;
select CURRENT_TIMESTAMP into @start_loop;
SET @sql = CONCAT('delete bv from optimus.borrowerValues bv
	join optimus._duplicatesToDelete d on bv.id = d.id;');
PREPARE s1 FROM @sql;
EXECUTE s1;
SELECT TIME_TO_SEC(TIMEDIFF(CURRENT_TIMESTAMP, @start_loop)) into last_loop_time;
call `datateam`.`job_log_steps_update`("loops_complete",loop_id);
call `datateam`.`job_log_steps_update`("last_loop_time",last_loop_time);
call `datateam`.`job_log_steps_update`("last_loop_time","Finished Step 4");
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);

-- Finish things up

call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);


END;;
DELIMITER ;



/* Instructions

Get the first Id from borrowerValues to start with:

select min(id) from borrowerValues where created > '2021-12-15 00:00:00';

Then update the sourceId's in the range you were looking at:

call `datateam`.`backfill_2021220_update_sourceId`(ID_FROM_ABOVE, 10000);

Then run the delete duplicates stored proc:

call `datateam`.`delete_borrowerValue_duplicates`(ID_FROM_ABOVE, 10000);

*/