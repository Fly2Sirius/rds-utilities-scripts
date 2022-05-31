DROP EVENT IF EXISTS `datateam`.`delete_old_apiLogs`;

DELIMITER ;;

CREATE EVENT `datateam`.`delete_old_apiLogs` ON SCHEDULE EVERY 1 DAY STARTS '2022-05-12 02:01:07' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Removes apiLogs records created 90 Days ago or greater' DO BEGIN
    call delete_old_apiLogs(10000);
    optimize table logs.apiLog;
END;;
DELIMITER ;