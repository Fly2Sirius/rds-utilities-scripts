DROP EVENT IF EXISTS `datateam`.`kill_orphaned_transactions`;

DELIMITER ;;

CREATE EVENT `datateam`.`kill_orphaned_transactions` ON SCHEDULE EVERY 1 MINUTE STARTS '2021-11-08 18:40:05' ON COMPLETION PRESERVE ENABLE COMMENT 'Kills Orphaned Transactions' DO BEGIN
	call `datateam`.`kill_orphaned`;
END;;
DELIMITER ;