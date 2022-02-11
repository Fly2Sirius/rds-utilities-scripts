DROP EVENT IF EXISTS `optimus`.`clear_oauth_token_logs`;

DELIMITER ;;

CREATE EVENT `optimus`.`clear_oauth_token_logs` ON SCHEDULE EVERY 1 DAY STARTS '2021-01-18 23:10:00' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Removes logs.oauthTokenLogs records created > 2 weeks ago' DO BEGIN 
    CALL optimus.clear_oauth_token_logs();
END;;
    
DELIMITER ;