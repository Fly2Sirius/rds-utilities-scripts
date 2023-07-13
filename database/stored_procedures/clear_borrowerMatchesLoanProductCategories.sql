DROP PROCEDURE IF EXISTS `optimus`.`clear_borrowerMatchesLoanProductCategories`;


DELIMITER ;;
CREATE PROCEDURE `optimus`.`clear_borrowerMatchesLoanProductCategories`(inIncrement int)
BEGIN
    REPEAT
        DO SLEEP(1); ## Optional, to minimise contention
        DELETE FROM borrowerMatchesLoanProductCategories
        WHERE modified < NOW() - INTERVAL 1 MONTH 
        ORDER BY modified asc
        LIMIT 100000; ## 10000 also works, this is more conservative      
    UNTIL ROW_COUNT() = 0 END REPEAT;
END;;
DELIMITER ;




-- CREATE INDEX created ON clear_borrowerMatchesLoanProductCategories (created); 