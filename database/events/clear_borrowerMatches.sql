DROP EVENT IF EXISTS `datateam`.`clear_borrowerMatches`;

DELIMITER ;;

CREATE EVENT `clear_borrowerMatches` ON SCHEDULE EVERY 1 DAY STARTS '2021-01-13 23:01:07' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Removes borrowerMatches records created 30 Days ago or greater' DO BEGIN
    CALL optimus.clear_borrower_matches();
END;;
DELIMITER ;