DROP PROCEDURE IF EXISTS `optimus`.`clear_borrowerMatchesLoanProducts`;


DELIMITER ;;
CREATE PROCEDURE `optimus`.`clear_borrowerMatchesLoanProducts`(inIncrement int)
BEGIN
    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM borrowerMatchesLoanProducts
        WHERE created < NOW() - INTERVAL 1 MONTH 
        ORDER BY created asc
        LIMIT 100000; ## 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;
END;;
DELIMITER ;




-- CREATE INDEX created ON clear_borrowerMatchesLoanProducts (created); 