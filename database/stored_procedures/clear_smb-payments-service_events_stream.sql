DROP PROCEDURE IF EXISTS `datateam`.`clear_smb-payments-service_event_stream`;

CREATE PROCEDURE datateam.`clear_smb-payments-service_event_stream`()
BEGIN
    call `datateam`.`job_log_start`("clear_smb-payments-service_event_stream",1,1,1,1,"Starting Job",@_log_id);

        -- Update the count of items to delete to the log table
    SET @rows_to_delete =  ( select count(*) from `smb-payments-service`.events_stream where created < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY) and published is not NULL);
    call `datateam`.`job_log_update`("start_id",@rows_to_delete);

    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM `smb-payments-service`.events_stream
        WHERE created <  DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY)
        AND published is not NULL
                -- ORDER BY id asc
        LIMIT 10000; -- 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;

    call `datateam`.`job_log_update`("status","Complete");
    call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END
