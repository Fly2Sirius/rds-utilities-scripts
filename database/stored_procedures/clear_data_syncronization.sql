DROP PROCEDURE IF EXISTS `datateam`.`clear_data_syncronizations`;


DELIMITER ;;
CREATE PROCEDURE `datateam`.`clear_data_syncronizations`(inIncrement int)
BEGIN
    call `datateam`.`job_log_start`("clear_data_syncronizations",1,1,1,1,"Starting Job",@_log_id);

    SET @rows_to_delete =  ( select count(*) from financial_integration.data_syncronizations where created_at < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY));
    
    call `datateam`.`job_log_update`("start_id",@rows_to_delete);

    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM data_syncronizations
        WHERE created_at < NOW() - INTERVAL 1 WEEK
        -- ORDER BY created_at asc
        LIMIT 1000; ## 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;

    call `datateam`.`job_log_update`("status","Complete");
    call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END;;
DELIMITER ;




-- CREATE INDEX created ON clear_borrowerMatchesLoanProducts (created); 