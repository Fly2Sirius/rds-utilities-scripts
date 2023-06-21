DROP EVENT IF EXISTS `datateam`.`update_bankservice_accounts_providerAccountId`;

DELIMITER ;;


CREATE DEFINER=`kdavey`@`10.%.%.%` EVENT `update_bankservice_accounts_providerAccountId` ON SCHEDULE EVERY 5 MINUTE STARTS '2023-05-22 13:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN

    call `datateam`.`job_log_start`("update bank_service_accounts",1,1,1,1,"Starting Job",@_log_id);

    update bank_service.accounts t
    set t.providerAccountid = case when t.id like "finicity%" then REPLACE(t.id,"finicity-","") 
        when t.id like "unit%" then REPLACE(t.id,"unit-","")
        ELSE t.id
    END 
    ,t.providerId = IF(SUBSTRING_INDEX(t.id, "-", 1) = "finicity",1,2)-- provider
    ,t.providerBankId =case when t.bankId like "finicity%" then REPLACE(t.bankId,"finicity-","") 
    when t.bankId like "unit%" then REPLACE(t.bankId,"unit-","")
        ELSE t.bankId
    END
    where t.providerAccountId is NULL;


    call `datateam`.`job_log_update`("status","Complete");
    call `datateam`.`job_log_update`("end",CURRENT_TIMESTAMP);

END;;
DELIMITER ;

