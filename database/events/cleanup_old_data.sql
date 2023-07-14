DROP EVENT IF EXISTS `datateam`.`cleanup_old_data`;

DELIMITER ;;

CREATE EVENT `datateam`.`cleanup_old_data` ON SCHEDULE EVERY 1 DAY STARTS '2023-03-07 23:01:07' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Event to call cleanup stored procs' DO 
BEGIN
    CALL datateam.clear_data_syncronizations(10);
    CALL datateam.clear_event_webhooks(10);
    CALL datateam.clear_jobs(10);
    CALL datateam.clear_bank_service_event_stream();
    CALL datateam.clear_business_service_event_stream();
    CALL datateam.clear_embedded_service_event_stream();
    CALL datateam.`clear_smb-payments-service_event_stream`();
END;;
DELIMITER ;