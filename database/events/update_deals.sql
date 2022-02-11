DROP EVENT IF EXISTS `datateam`.`update_deals`;

DELIMITER ;;

CREATE EVENT `update_deals` ON SCHEDULE EVERY 2 HOUR STARTS '2021-02-08 09:20:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE deals d
		INNER JOIN offers o ON d.id = o.dealId AND o.accepted IS NOT NULL AND o.deleted IS NULL
	SET d.acceptedOfferId = o.id
	, d.modified = NOW()
	WHERE d.dateClosed IS NOT NULL
	AND d.stage = 'funded'
	AND d.deleted IS NULL
	AND d.acceptedOfferId IS NULL;
END;;
DELIMITER ;