DROP PROCEDURE IF EXISTS `optimus`.`clear_borrowerMatchesClassifications`;


DELIMITER ;;
CREATE PROCEDURE `optimus`.`clear_borrowerMatchesClassifications`(inIncrement int)
BEGIN
    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM borrowerMatchesClassifications
        WHERE created < NOW() - INTERVAL 1 MONTH 
        ORDER BY created asc
        LIMIT 100000; ## 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;
END;;
DELIMITER ;




-- CREATE INDEX created ON borrowerMatchesClassifications (created); 