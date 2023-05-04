DROP EVENT IF EXISTS `datateam`.`import_partner_data`;

DELIMITER ;;

CREATE EVENT `datateam`.`import_partner_data` ON SCHEDULE EVERY 5 MINUTE STARTS '2023-02-03 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Imports partner affiliate ownership data.' DO BEGIN

SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

call datateam.log('import_partner_data - Deals','start');

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/deals/partner-affiliate-deals.csv'
    INTO TABLE `optimus`.`partnerDeals`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (@dummy,`dealId`,`borrowerId`,`dealType`,`productType`,`applicationStatus`,`term`,`dealClosedAt`,`fundedAmount`,`commissionAmount`,`payoutAmount`,`applicationStartedAt`,`applicationCompletedAt`,`dealSentAt`,`docPrepAt`,`offerReceived`,`offerReceivedCount`,`activityCount`,`marketingId`,`created`,`modified`,`parentDealId`,`offerAccepted`,`borrowerStage`)
        
call datateam.log(NULL,'end');






SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

call datateam.log('import_partner_data - OwnershipWindows','start');

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/ownership/partner-affiliate-ownership.csv'
    INTO TABLE `optimus`.`partnerOwnershipWindows`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (`affiliateId`,`parentAffiliateId`,`borrowerId`,`marketingId`,`ownershipStart`,`ownershipEnd`,`borrowerName`,`doingBusinessAs`,`email`,`campaign`,`adGroup`,`medium`,`landingPage`,`firstContactedAt`,`applicationStartedAt`,`applicationCompletedAt`,`dealSentAt`,`docPrepAt`,`offerReceived`,`mineralGroup`,`borrowerMineralGroup`,`isQualified`,`dealClosedAt`,`lastLoginAt`,`borrowerCreatedAt`,`created`,`modified`)
        
call datateam.log(NULL,'end');






SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

call datateam.log('import_partner_data - partnerOpportunities','start');

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/opportunities/partner-affiliate-opportunities.csv'
    INTO TABLE `optimus`.`partnerOpportunities`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (`borrowerId`,`opportunityStartAt`,`opportunityEndAt`,`startReason`,`startMineralGroup`,`endMineralGroup`,`isQualifiedStart`,`isQualifiedEnd`,`firstContactedAt`,`applicationStartedAt`,`applicationCompletedAt`,`dealSentAt`,`docPrepAt`,`offerReceived`,`dealCreatedAt`,`dealClosedAt`,`activityCount`,`marketingId`,`created`,`modified`)
        
call datateam.log(NULL,'end');



END;;
DELIMITER ;



