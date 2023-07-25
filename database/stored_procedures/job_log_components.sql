---------------------------------------------------------------------------------------------------
--
-- These tables store info about jobs run through stored procs especially for looping jobs.
--
-- job_log -- table sets logging for the overall job, specifically full start and end times, the number of steps (looping queries) the job has and the progress of the job overall.
--            If you are trying to track start and end times on a simple job with now loops, just set the steps to 0
--
-- job_log_steps -- table contains the logging for each looping step within a job, loops complete, total loops, etc.
--
-- job_log_time_estimate -- view contains summarized infor per job and estimates for completion.
--
-- To keep it simple you just call the job_log_start sp in the beginning of the script, call job_log_update to update the table as the script progresses, and the same job_log_steps_start and job_log_steps_update to update individual columns as the steps progress.
--
-- call `datateam`.`job_log_start`(JOB_NAME,NUMBER_OF_STEPS,CURRENT_STEP,NUMBER_TO_INCREMENT,ID_TO_START_ON,MESSAGE,@_log_id);
-- 
-- call `datateam`.`job_log_update`(COLUMN,VALUE);
--
-- call `datateam`.`job_log_steps_start`(@_log_id,STEP_NUMBER,STEP_DESCRIPTION,ROWS_TO_UPDATE,INCREMENT_VALUE,ID_TO_START_AT,ID_OF_LAST,STATUS_MESSAGE,@_log_step_id);
--
-- call `datateam`.`job_log_steps_update`(COLUMN,VALUE);
--
--------------------------------------------------------------------------------------------------- 

CREATE DATABASE IF NOT EXISTS `datateam`;

USE `datateam`;

CREATE TABLE  IF NOT EXISTS `datateam`.`job_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) DEFAULT NULL,
  `step_total` tinyint(4) NOT NULL DEFAULT '1',
  `step_current` tinyint(4) NOT NULL DEFAULT '1',
  `increment` int(11) unsigned DEFAULT NULL,
  `start_id` int(11) unsigned DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `end` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `datateam`.`job_log_steps` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int(10) unsigned DEFAULT NULL,
  `step_number` tinyint(4) NOT NULL DEFAULT 1,
  `step_name` varchar(30) DEFAULT NULL,
  `rows_to_update` int(10) unsigned DEFAULT NULL,
  `increment` int(10) unsigned NOT NULL DEFAULT 1,
  `loops_total` int(10) unsigned DEFAULT NULL,
  `loops_complete` int(10) unsigned DEFAULT NULL,
  `last_loop_time` int(10) unsigned DEFAULT NULL,
  `total_rows_to_update` int(10) unsigned DEFAULT NULL,
  `rows_updated` int(10) unsigned DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `end` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE OR REPLACE VIEW `datateam`.`job_log_time_estimates` as
SELECT
    `l`.`job_name` AS `Job Name`,
    `s`.`step_name` AS `Step Name`,
    `s`.`loops_total` AS `Total Loops`,
    `s`.`loops_complete` AS `Current Loop`,
    concat(round(((`s`.`loops_complete` / `s`.`loops_total`) * 100), 1), '%') AS `Percent Complete (Loops)`,
    `s`.`increment` AS `increment`,
    `s`.`start` AS `Step Start`,
    `s`.`end` AS `Step End`,
    `s`.`total_rows_to_update` as `Total Number Of Rows To Update`,
    `s`.`rows_updated` as `Number Of Rows Updated`,
    concat(round(((`s`.`rows_updated` / `s`.`total_rows_to_update`) * 100), 1), '%') AS `Percent Complete (Rows)`,
    timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) AS `Run Time (Min)`,
    round((timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) / 60), 2) AS `Run Time (hr)`,
    round(((timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) / `s`.`loops_complete`) * (`s`.`loops_total` - `s`.`loops_complete`)), 0) AS `Est Time Remaining`,
    (timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) + round(((timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) / `s`.`loops_complete`) * (`s`.`loops_total` - `s`.`loops_complete`)), 0)) AS `Estimated Total Run Time`,
    if((round(((timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) / `s`.`loops_complete`) * (`s`.`loops_total` - `s`.`loops_complete`)), 0) > 0), (now() + interval round((((timestampdiff(MINUTE, `s`.`start`, ifnull(`s`.`end`, now())) / `s`.`loops_complete`) * (`s`.`loops_total` - `s`.`loops_complete`)) * 2.25), 0)
minute), NULL) AS `Estimated Completion Time`
    FROM (`datateam`.`job_log_steps` `s`
    JOIN `datateam`.`job_log` `l` ON ((`s`.`job_id` = `l`.`id`)));


DROP PROCEDURE IF EXISTS `datateam`.`job_log_start`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`job_log_start`(inJobName varchar(30),inStepTotal int, inStepCurrent int,inIncrement int,inStartId int,inStatus varchar(50), OUT _log_id int unsigned)
proc_Exit:BEGIN
SET @insert_sql = CONCAT('insert into `datateam`.`job_log` (id,job_name,step_total,step_current,increment,start_id,status) VALUES (NULL,"',inJobName,'",',inStepTotal,',',inStepCurrent,',',inIncrement,',',inStartId,',"',inStatus,'");');
PREPARE s1 FROM @insert_sql;
EXECUTE s1;
SET _log_id := LAST_INSERT_ID();
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `datateam`.`job_log_update`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`job_log_update`(inColumn varchar(30),inColumnValue varchar(30))
proc_Exit:BEGIN
    SET @update_sql = CONCAT('update `datateam`.`job_log` 
        set ',inColumn,' = "',inColumnValue,'"
        where id = ',@_log_id,';');
    -- select @update_sql;
    PREPARE s1 FROM @update_sql;
    EXECUTE s1;  
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `datateam`.`job_log_steps_start`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`job_log_steps_start`(inJobId int unsigned, inStepNumber int unsigned,inStepName varchar(30),inRowsToUpdate int unsigned,inIncrement int, inStartId int,inMaxId int,inStatus varchar(50), OUT _log_step_id int unsigned)
proc_Exit:BEGIN
    DECLARE loops_total int;
    SET loops_total = IFNULL(((inMaxId - inStartId)/inIncrement) + 1,0);
    SET @insert_sql = CONCAT('insert into `datateam`.`job_log_steps` (id,job_id,step_number,step_name,rows_to_update,increment,loops_total,`status`) VALUES (NULL,',inJobId,',',inStepNumber,',"',inStepName,'",',inRowsToUpdate,',',inIncrement,',',loops_total,',"',inStatus,'");');
    -- select @insert_sql;
    PREPARE s1 FROM @insert_sql;
    EXECUTE s1;  
    SET `_log_step_id` := LAST_INSERT_ID();
    
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `datateam`.`job_log_steps_update`;

DELIMITER ;;
CREATE PROCEDURE `datateam`.`job_log_steps_update`(inColumn varchar(30),inColumnValue varchar(30))
proc_Exit:BEGIN
    SET @update_sql = CONCAT('update `datateam`.`job_log_steps` 
        set ',inColumn,' = "',inColumnValue,'"
        where id = ',@_log_step_id,';');
    PREPARE s1 FROM @update_sql;
    EXECUTE s1;  
END;;
DELIMITER ;