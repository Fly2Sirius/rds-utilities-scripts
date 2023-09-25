-- DROP EVENT IF EXISTS `datateam`.`import_eligibility_data`;

-- DELIMITER ;;

-- CREATE EVENT `datateam`.`import_eligibility_data` ON SCHEDULE EVERY 1 DAY STARTS '2023-09-26 06:05:00' ON COMPLETION PRESERVE ENABLE COMMENT 'Imports eligibility data.' DO BEGIN

call datateam.log('Import Eligibility Data','start');

truncate table `optimus`.`borrowerRenewalEligibilityEstimates`;

LOAD DATA FROM S3  'S3://lendio-snowflake-exports/eligibility/renewal_eligibility.csv'
    INTO TABLE `optimus`.`borrowerRenewalEligibilityEstimates`
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (@dummy,`borrowerid`,`estimatedRenewalEligibility`);
        
call datateam.log(NULL,'end');

-- END;;
-- DELIMITER ;



-- 05 06 * * *  ec2-user /home/ec2-user/partnerSpiff/import_eligibility_data.sh
-- mysql --defaults-extra-file=/home/ec2-user/.my.cnf -hproduction-cluster-1.cluster-civpyhkigzas.us-east-1.rds.amazonaws.com optimus < /home/ec2-user/partnerSpiff/import_eligibility_data.sqld