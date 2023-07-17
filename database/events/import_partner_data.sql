DROP EVENT IF EXISTS `datateam`.`import_partner_data`;

DELIMITER ;;

CREATE EVENT `datateam`.`import_partner_data` ON SCHEDULE EVERY 5 MINUTE STARTS '2023-02-03 11:00:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Imports partner data.' DO BEGIN

call datateam.log('import_partner_data - Deals','start');

truncate table `optimus`.`partnerDeals`;


LOAD DATA FROM S3  'S3://lendio-snowflake-exports/deals/partner-affiliate-deals.csv'
    INTO TABLE `optimus`.`partnerDeals`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (@dummy,`marketingId`,`ownershipStart`,`ownershipEnd`,`borrowerid`,`dealId`,`dealCreatedAt`,`dealStatus`,`dealStage`,`dealType`,`productType`,`term`,`dealSentAt`,`docPrepAt`,`offerReceivedAt`,`offerReceivedCount`, `offerAcceptedAt`,`dealClosedAt`,`fundedAmount`,`commissionAmount`,`payoutAmount`,`activityCount`,`salesRep`,`parentDealId`)
        
call datateam.log(NULL,'end');

call datateam.log('import_partner_data - OwnershipWindows','start');




truncate table `optimus`.`partnerOwnershipWindows`;

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/ownership/partner-affiliate-ownership.csv'
    INTO TABLE `optimus`.`partnerOwnershipWindows`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (@dummy,`affiliateId`,`parentAffiliateId`,`marketingId`,`ownershipStart`,`ownershipEnd`,`borrowerid`,`borrowerName`,`doingBusinessAs`,`email`,`campaign`,`adGroup`,`medium`,`landingPage`,`mineralGroup`,`borrowerMineralGroup`,`isQualified`,`applicationStatus`,`borrowerStage`,`applicationStartedAt`,`applicationCompletedAt`,`firstAttemptedAt`,`firstContactedAt`,`dealCreatedAt`,`dealSentAt`,`docPrepAt`,`offerReceivedAt`,`offerAcceptedAt`,`dealClosedAt`,`salesRep`,`lastLoginAt`,`leadReceivedAt`)
        
call datateam.log(NULL,'end');


call datateam.log('import_partner_data - Leads','start');

truncate table `optimus`.`partnerLeads`;

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/leads/partner-affiliate-leads.csv'
    INTO TABLE `optimus`.`partnerLeads`
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (@dummy,`borrowerId`,`marketingId`,`ownershipMarketingId`,`ownershipStart`,`ownershipEnd`,`leadResult`,`leadReceivedAt`,`email`,`campaign`,`landingPage`,`capturePage`,`subId`,`adGroup`,`term`,`isQualified`)

call datateam.log(NULL,'end');



END;;
DELIMITER ;