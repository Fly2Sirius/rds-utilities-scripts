DROP EVENT IF EXISTS `datateam`.`clear_borrowerMatches`;

DELIMITER ;;

CREATE EVENT `datateam`.`delete_old_hubspot_logs` ON SCHEDULE EVERY 1 WEEK STARTS '2021-10-23 19:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    call datateam.delete_old_hubspotlogs(1000);
ENDD;;
DELIMITER ;