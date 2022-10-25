

DROP PROCEDURE IF EXISTS `optimus`.`clear_borrower_matches`;


DELIMITER ;;
CREATE PROCEDURE `optimus`.`clear_borrower_matches`(inIncrement int)
BEGIN
    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM borrowerMatches
        WHERE created < NOW() - INTERVAL 1 MONTH 
        ORDER BY created asc
        LIMIT 100000; ## 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;
END;;
DELIMITER ;





