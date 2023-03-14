DROP EVENT IF EXISTS `datateam`.`clear_data_syncronizations`;

DELIMITER ;;

CREATE EVENT `datateam`.`clear_data_syncronizations` ON SCHEDULE EVERY 1 DAY STARTS '2023-03-07 23:01:07' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Removes data_syncronizations records created 7 Days ago or longer' DO 
BEGIN
    CALL datateam.clear_data_syncronizations(10);
END;;
DELIMITER ;