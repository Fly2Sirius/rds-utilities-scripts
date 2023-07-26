DROP EVENT IF EXISTS `datateam`.`capture_locks`;

DELIMITER ;;

CREATE  EVENT `datateam`.`capture_locks` ON SCHEDULE EVERY 1 MINUTE STARTS '2022-02-15 16:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Inserts locking data into datateam.lockdata table' DO BEGIN

call `datateam`.`job_log_start`("capture_locks",1,0,0,0,"Starting",@_log_id);

insert into datateam.lockdata (`waiting_trx_id`,  `waiting_thread`, `waiting_query` , `blocking_trx_id`, `blocking_thread` , `blocking_query`)              
    SELECT
r.trx_id waiting_trx_id,
r.trx_mysql_thread_id waiting_thread,
r.trx_query waiting_query,
b.trx_id blocking_trx_id,
b.trx_mysql_thread_id blocking_thread,
b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b
ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r
ON r.trx_id = w.requesting_trx_id
order by blocking_thread;

call `datateam`.`job_log_update`("errors",@@error_count);
call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END