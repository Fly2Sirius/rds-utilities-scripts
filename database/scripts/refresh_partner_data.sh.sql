-- This script runs off the perconae server under the ec2-user user

use optimus;

call `datateam`.`job_log_start`("import_partner_data",4,0,0,0,"Starting",@_log_id);


-- STEP 1
call `datateam`.`job_log_update`("status","Running Step 1");
call `datateam`.`job_log_update`("step_current",1);
call `datateam`.`job_log_steps_start`(@_log_id,1,"partnerDeals",0,0,0,0,"Starting First Step",@_log_step_id);
-- Drop if exists temp table
drop table if exists optimus._partnerDeals;
-- Create temp table
create table optimus._partnerDeals like optimus.partnerDeals;
-- Load Data into new table
LOAD DATA FROM S3  'S3://lendio-snowflake-exports/deals/partner-affiliate-deals.csv'
    INTO TABLE `optimus`.`_partnerDeals`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (@dummy,`marketingId`,`ownershipStart`,`ownershipEnd`,`borrowerid`,`dealId`,`dealCreatedAt`,`dealStatus`,`dealStage`,`dealType`,`productType`,`term`,`dealSentAt`,`docPrepAt`,`offerReceivedAt`,`offerReceivedCount`, `offerAcceptedAt`,`dealClosedAt`,`fundedAmount`,`commissionAmount`,`payoutAmount`,`activityCount`,`salesRep`,`parentDealId`);
-- Get count update log record
select count(*) into @count from `optimus`.`partnerDeals`;
call `datateam`.`job_log_steps_update`("increment",@count);
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);




-- STEP 2
call `datateam`.`job_log_update`("status","Running Step 2");
call `datateam`.`job_log_update`("step_current",2);
call `datateam`.`job_log_steps_start`(@_log_id,2,"partnerOwnershipWindows",0,0,0,0,"Starting Second Step",@_log_step_id);
-- Drop if exists temp table
drop table if exists optimus._partnerOwnershipWindows;
-- Create temp table
create table optimus._partnerOwnershipWindows like optimus.partnerOwnershipWindows;
-- Load Data into new table
LOAD DATA FROM S3  'S3://lendio-snowflake-exports/ownership/partner-affiliate-ownership.csv'
    INTO TABLE `optimus`.`_partnerOwnershipWindows`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (@dummy,`affiliateId`,`parentAffiliateId`,`marketingId`,`ownershipStart`,`ownershipEnd`,`borrowerid`,`borrowerName`,`doingBusinessAs`,`email`,`campaign`,`adGroup`,`medium`,`landingPage`,`mineralGroup`,`borrowerMineralGroup`,`isQualified`,`applicationStatus`,`borrowerStage`,`applicationStartedAt`,`applicationCompletedAt`,`firstAttemptedAt`,`firstContactedAt`,`dealCreatedAt`,`dealSentAt`,`docPrepAt`,`offerReceivedAt`,`offerAcceptedAt`,`dealClosedAt`,`salesRep`,`lastLoginAt`,`leadReceivedAt`);
-- Get count update log record
select count(*) into @count from `optimus`.`partnerOwnershipWindows`;
call `datateam`.`job_log_steps_update`("increment",@count);
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);



-- STEP 3
call `datateam`.`job_log_update`("status","Running Step 3");
call `datateam`.`job_log_update`("step_current",3);
call `datateam`.`job_log_steps_start`(@_log_id,3,"partnerLeads",0,0,0,0,"Starting Third Step",@_log_step_id);
-- Drop if exists temp table
drop table if exists optimus._partnerLeads;
-- Create temp table
create table optimus._partnerLeads like optimus.partnerLeads;
-- Load Data into new table
LOAD DATA FROM S3  'S3://lendio-snowflake-exports/leads/partner-affiliate-leads.csv'
    INTO TABLE `optimus`.`_partnerLeads`
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (@dummy,`borrowerId`,`marketingId`,`ownershipMarketingId`,`ownershipStart`,`ownershipEnd`,`leadResult`,`leadReceivedAt`,`email`,`campaign`,`landingPage`,`capturePage`,`subId`,`adGroup`,`term`,`isQualified`);
-- Get count update log record
select count(*) into @count from `optimus`.`partnerLeads`;
call `datateam`.`job_log_steps_update`("increment",@count);
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);



-- STEP 4 - Rename/Drop tables
call `datateam`.`job_log_update`("status","Running Step 4");
call `datateam`.`job_log_update`("step_current",4);
call `datateam`.`job_log_steps_start`(@_log_id,4,"Renaming Tables",0,0,0,0,"Starting Fourth Step",@_log_step_id);

rename table optimus.partnerDeals to optimus._partnerDeals_ToDelete;
rename table optimus._partnerDeals to optimus.partnerDeals;
drop table if exists optimus._partnerDeals_ToDelete;

rename table optimus.partnerLeads to optimus._partnerLeads_ToDelete;
rename table optimus._partnerLeads to optimus.partnerLeads;
drop table if exists optimus._partnerLeads_ToDelete;

rename table optimus.partnerOwnershipWindows to optimus._partnerOwnershipWindows_ToDelete;
rename table optimus._partnerOwnershipWindows to optimus.partnerOwnershipWindows;
drop table if exists optimus._partnerOwnershipWindows_ToDelete;
call `datateam`.`job_log_steps_update`("end",CURRENT_TIMESTAMP);


-- Close out job
call `datateam`.`job_log_update`("errors",@@error_count);
call `datateam`.`job_log_update`("status","Complete");
call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);


# 15 * * * * /home/ec2-user/partnerSpiff/refresh_partner_data.sh
# mysql --defaults-extra-file=/home/ec2-user/.my.cnf -hproduction-cluster-1.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com optimus < /home/ec2-user/partnerSpiff/import_partner_data.sql