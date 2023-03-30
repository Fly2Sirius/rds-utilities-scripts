DROP PROCEDURE IF EXISTS `datateam`.`clear_event_webhooks`;


DELIMITER ;;
CREATE PROCEDURE `datateam`.`clear_event_webhooks`(inIncrement int)
BEGIN
    call `datateam`.`job_log_start`("clear_event_webhooks",1,1,1,1,"Starting Job",@_log_id);

    SET @rows_to_delete =  ( select count(*) from bank_service.event_webhooks where created < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY));
    
    call `datateam`.`job_log_update`("start_id",@rows_to_delete);

    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM bank_service.event_webhooks
        WHERE created < NOW() - INTERVAL 1 WEEK
        -- ORDER BY created_at asc
        LIMIT 1000; ## 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;

    call `datateam`.`job_log_update`("status","Complete");
    call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END;;
DELIMITER ;




-- CREATE INDEX created ON clear_borrowerMatchesLoanProducts (created); 