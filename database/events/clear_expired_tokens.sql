DROP EVENT IF EXISTS `datateam`.`clear_expired_tokens`;

DELIMITER ;;

CREATE EVENT `datateam`.`clear_expired_tokens` ON SCHEDULE EVERY 5 MINUTE STARTS '2022-03-30 14:25:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

delete os,osat from oauth.oauth_sessions os
join oauth.oauth_session_access_tokens osat on os.id = osat.session_id
where osat.access_token_expires < unix_timestamp(current_timestamp);

delete os from oauth.oauth_sessions os
left join oauth.oauth_session_access_tokens osat on os.id = osat.session_id
where osat.id is NULL;

delete from `optimus`.`oauth_access_tokens` where expires_at < current_timestamp;

END;;
DELIMITER ;