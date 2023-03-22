DROP EVENT IF EXISTS `datateam`.`import_affiliate_data`;

DELIMITER ;;

CREATE EVENT `datateam`.`import_affiliate_data` ON SCHEDULE EVERY 5 MINUTE STARTS '2023-02-03 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Imports partner affiliate ownership data.' DO BEGIN

SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

call datateam.log('import_affiliate_data','start');

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/ownership/partner-affiliate-ownership.csv'
    INTO TABLE `optimus`.`partnerAffiliateOwnership`
        FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
        IGNORE 1 LINES
    (processingId,borrowerId,leadSourceId, loadedAt,processingAt,completedAt,batchId,error);

call datateam.log(NULL,'end');
END;;
DELIMITER ;