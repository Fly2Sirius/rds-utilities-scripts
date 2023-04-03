DROP EVENT IF EXISTS `datateam`.`update_affiliate_data`;

DELIMITER ;;

CREATE EVENT `datateam`.`update_affiliate_data` ON SCHEDULE EVERY 5 MINUTE STARTS '2023-02-03 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Imports partner affiliate ownership data.' DO BEGIN

SET @timestamp = (select unix_timestamp(CURRENT_TIMESTAMP));

call datateam.log('update_affiliate_data','start');

drop table if exists partnerAffiliateOwnershipReport_temp;

create table partnerAffiliateOwnershipReport_temp like partnerAffiliateOwnershipReport;

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/ownership/partner-affiliate-ownership-UPDATE.csv'
    INTO TABLE `optimus`.`partnerAffiliateOwnershipReport_temp`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (`processingId`, `affiliateId` ,`parentAffiliateId`,`borrowerId`,`marketingId`,`ownershipStart`,`ownershipEnd`,`name` ,`doingBusinessAs`,`email` ,`loanType` ,`productType` ,`applicationStatus`,`campaign` ,`adGroup` ,`medium`,`term` ,`landingPage` ,`firstContactedAt`,`applicationStartedAt` ,`applicationCompletedAt` ,`offerReceived` ,`offerReceivedCount` ,`activityCount` ,`marketingMineralGroup`,`borrowerMineralGroup`,`isQualified`,`dateClosed`,`originationAmount` ,`totalRevenue` ,`payoutAmount` ,`borrowerCreatedAt` ,`processingAt` ,`completedAt` ,`batchId` ,`error`)



insert into partnerAffiliateOwnershipReport
    (`processingId`, `affiliateId` ,`parentAffiliateId`,`borrowerId`,`marketingId`,`ownershipStart`,`ownershipEnd`,`name` ,`doingBusinessAs`,`email` ,`loanType` ,`productType` ,`applicationStatus`,`campaign` ,`adGroup` ,`medium`,`term` ,`landingPage` ,`firstContactedAt`,`applicationStartedAt` ,`applicationCompletedAt` ,`offerReceived` ,`offerReceivedCount` ,`activityCount` ,`marketingMineralGroup`,`borrowerMineralGroup`,`isQualified`,`dateClosed`,`originationAmount` ,`totalRevenue` ,`payoutAmount` ,`borrowerCreatedAt` ,`processingAt` ,`completedAt` ,`batchId` ,`error`)
    select `processingId`, `affiliateId` ,`parentAffiliateId`,`borrowerId`,`marketingId`,`ownershipStart`,`ownershipEnd`,`name` ,`doingBusinessAs`,`email` ,`loanType` ,`productType` ,`applicationStatus`,`campaign` ,`adGroup` ,`medium`,`term` ,`landingPage` ,`firstContactedAt`,`applicationStartedAt` ,`applicationCompletedAt` ,`offerReceived` ,`offerReceivedCount` ,`activityCount` ,`marketingMineralGroup`,`borrowerMineralGroup`,`isQualified`,`dateClosed`,`originationAmount` ,`totalRevenue` ,`payoutAmount` ,`borrowerCreatedAt` ,`processingAt` ,`completedAt` ,`batchId` ,`error`
    from partnerAffiliateOwnershipReport_temp t
    ON DUPLICATE KEY UPDATE `processingId` = t.`processingId`
        ,`affiliateId` = t.`affiliateId`
        ,`parentAffiliateId` = t.`parentAffiliateId`
        ,`ownershipStart` = t.`ownershipStart`
        ,`ownershipEnd` = t.`ownershipEnd` 
        ,`name` = t.`name`
        ,`doingBusinessAs` = t.`doingBusinessAs`
        ,`email` = t.`email`
        ,`loanType`  = t.`loanType`
        ,`productType` = t.`productType` 
        ,`applicationStatus` = t.`applicationStatus`
        ,`campaign` = t.`campaign` 
        ,`adGroup` = t.`adGroup` 
        ,`medium` = t.`medium`
        ,`term` = t.`term`
        ,`landingPage` = t.`landingPage` 
        ,`firstContactedAt` = t.`firstContactedAt`
        ,`applicationStartedAt` = t.`applicationStartedAt` 
        ,`applicationCompletedAt` = t.`applicationCompletedAt` 
        ,`offerReceived` = t.`offerReceived`
        ,`offerReceivedCount` = t.`offerReceivedCount` 
        ,`activityCount` = t.`activityCount` 
        ,`marketingMineralGroup` = t.`marketingMineralGroup`
        ,`borrowerMineralGroup` = t.`borrowerMineralGroup`
        ,`isQualified` = t.`isQualified`
        ,`dateClosed` = t.`dateClosed`
        ,`originationAmount` = t.`originationAmount` 
        ,`totalRevenue` = t.`totalRevenue`
        ,`payoutAmount` = t.`payoutAmount`
        ,`borrowerCreatedAt` = t.`borrowerCreatedAt` 
        ,`processingAt` = t.`processingAt`
        ,`completedAt` = t.`completedAt`
        ,`batchId` = t.`batchId`
        ,`error` = t.`error`;

drop table if exists partnerAffiliateOwnershipReport_temp;

call datateam.log(NULL,'end');
END;;
DELIMITER ;